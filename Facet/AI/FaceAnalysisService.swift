//
//  FaceAnalysisService.swift
//  Facet
//
//  The on-device analysis pipeline. Given a photo the user chose, it uses Apple's
//  Vision framework to detect the face, map landmarks, read head pose, score
//  capture quality, generate a feature print (for on-device similarity), and
//  classify the scene for smart tags. Core Image supplies exposure and sharpness.
//  A `FaceInsightModel` turns geometry into clearly-labelled age / emotion
//  estimates. Nothing leaves the device.
//

import Vision
import UIKit
import CoreGraphics

enum AnalysisError: LocalizedError {
    case invalidImage
    var errorDescription: String? {
        switch self {
        case .invalidImage: return "That image couldn't be read. Try another photo."
        }
    }
}

final class FaceAnalysisService {
    static let shared = FaceAnalysisService()

    private let insightModel: FaceInsightModel
    private let metrics = ImageMetrics.shared

    init(insightModel: FaceInsightModel = HeuristicInsightModel()) {
        self.insightModel = insightModel
    }

    /// Analyse a photo end-to-end on a background queue and return a value type.
    func analyze(_ image: UIImage) async throws -> FaceAnalysis {
        guard let cgImage = image.cgImage else { throw AnalysisError.invalidImage }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let analysis = try self.runPipeline(image: image, cgImage: cgImage, orientation: orientation)
                    continuation.resume(returning: analysis)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Pipeline

    private func runPipeline(image: UIImage, cgImage: CGImage, orientation: CGImagePropertyOrientation) throws -> FaceAnalysis {
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

        let landmarksRequest = VNDetectFaceLandmarksRequest()
        let qualityRequest   = VNDetectFaceCaptureQualityRequest()
        let featureRequest   = VNGenerateImageFeaturePrintRequest()
        let classifyRequest  = VNClassifyImageRequest()

        try handler.perform([landmarksRequest, qualityRequest, featureRequest, classifyRequest])

        // Largest detected face (if any).
        let faces = (landmarksRequest.results ?? []).sorted {
            $0.boundingBox.width * $0.boundingBox.height > $1.boundingBox.width * $1.boundingBox.height
        }
        let face = faces.first
        let faceDetected = face != nil

        // Feature print for on-device similarity.
        let featurePrintObs = featureRequest.results?.first

        // Geometry → image-normalised landmarks + head pose.
        let bbox = face.map { topLeftRect(from: $0.boundingBox) } ?? CGRect(x: 0.25, y: 0.2, width: 0.5, height: 0.6)
        let landmarks = face.flatMap { imageLandmarks(for: $0) } ?? []
        let roll  = degrees(face?.roll)
        let yaw   = degrees(face?.yaw)
        let pitch = degrees(face?.pitch)

        // Capture-quality (match the quality observation to the same face by IoU).
        let quality = bestQuality(for: face, in: qualityRequest.results ?? [])

        // Exposure + sharpness, measured on the face crop when available.
        let measureImage = faceCrop(of: cgImage, boundingBox: face?.boundingBox) ?? cgImage
        let brightness = metrics.brightness(of: measureImage)
        let sharpness  = metrics.sharpness(of: measureImage)
        let lighting   = lightingProfile(brightness: brightness, sharpness: sharpness)

        // Estimates (age / emotion) from real facial geometry.
        let signals = faceSignals(for: face, featurePrint: featurePrintObs?.data, yaw: yaw, pitch: pitch)
        let estimate = insightModel.estimate(from: signals)

        // Smart tags from scene classification + face attributes.
        let tags = smartTags(classify: classifyRequest.results ?? [],
                             faceDetected: faceDetected,
                             lighting: lighting,
                             sharpness: sharpness)

        // Build the analysis.
        var analysis = FaceAnalysis(
            image: image,
            faceDetected: faceDetected,
            faceBoundingBox: bbox,
            landmarks: landmarks,
            roll: roll, yaw: yaw, pitch: pitch,
            qualityScore: quality,
            sharpness: sharpness,
            brightness: brightness,
            lighting: lighting,
            age: estimate.age,
            emotions: estimate.emotions,
            moodLabel: estimate.moodLabel,
            moodConfidence: estimate.moodConfidence,
            tags: tags,
            summary: "",
            featurePrint: featurePrintObs,
            duplicateCount: 0
        )
        analysis.summary = summary(for: analysis)
        return analysis
    }

    // MARK: - Geometry helpers

    /// Convert a Vision bounding box (normalised, bottom-left origin) to a
    /// top-left-origin normalised rect suitable for SwiftUI drawing.
    private func topLeftRect(from bb: CGRect) -> CGRect {
        CGRect(x: bb.origin.x, y: 1 - bb.origin.y - bb.height, width: bb.width, height: bb.height)
    }

    /// All landmark points mapped into image space (0…1, top-left origin).
    private func imageLandmarks(for face: VNFaceObservation) -> [CGPoint]? {
        guard let points = face.landmarks?.allPoints?.normalizedPoints else { return nil }
        let bb = face.boundingBox
        return points.map { p in
            CGPoint(x: bb.origin.x + p.x * bb.width,
                    y: 1 - (bb.origin.y + p.y * bb.height))
        }
    }

    private func degrees(_ radians: NSNumber?) -> Double {
        guard let r = radians?.doubleValue else { return 0 }
        return r * 180 / .pi
    }

    /// Match the capture-quality observation that overlaps the chosen face.
    private func bestQuality(for face: VNFaceObservation?, in observations: [VNFaceObservation]) -> Double {
        guard let face else { return observations.first?.faceCaptureQuality.map(Double.init) ?? 0.5 }
        let match = observations.max { a, b in
            iou(a.boundingBox, face.boundingBox) < iou(b.boundingBox, face.boundingBox)
        }
        return match?.faceCaptureQuality.map(Double.init) ?? 0.5
    }

    private func iou(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let inter = a.intersection(b)
        guard !inter.isNull else { return 0 }
        let interArea = inter.width * inter.height
        let union = a.width * a.height + b.width * b.height - interArea
        return union > 0 ? interArea / union : 0
    }

    private func faceCrop(of cgImage: CGImage, boundingBox: CGRect?) -> CGImage? {
        guard let bb = boundingBox else { return nil }
        let w = CGFloat(cgImage.width), h = CGFloat(cgImage.height)
        let rect = CGRect(x: bb.origin.x * w,
                          y: (1 - bb.origin.y - bb.height) * h,
                          width: bb.width * w,
                          height: bb.height * h).integral
        guard rect.width > 8, rect.height > 8 else { return nil }
        return cgImage.cropping(to: rect)
    }

    // MARK: - Signals

    private func faceSignals(for face: VNFaceObservation?, featurePrint: Data?, yaw: Double, pitch: Double) -> FaceSignals {
        guard let landmarks = face?.landmarks else {
            return FaceSignals(smile: 0.3, mouthOpen: 0.1, eyeOpen: 0.5, symmetry: 0.9,
                               featurePrint: featurePrint, yaw: yaw, pitch: pitch)
        }

        // Smile: mouth-corner lift relative to the mouth centroid.
        var smile = 0.35
        if let lips = landmarks.outerLips?.normalizedPoints, lips.count > 3 {
            let centroid = lips.centroid
            let left = lips.min { $0.x < $1.x } ?? centroid
            let right = lips.max { $0.x < $1.x } ?? centroid
            let cornerY = (left.y + right.y) / 2
            let height = max(lips.bounds.height, 0.0001)
            smile = clamp(0.4 + Double((cornerY - centroid.y) / height) * 0.8, 0, 1)
        }

        // Mouth openness: inner-lip vertical separation vs width.
        var mouthOpen = 0.1
        if let inner = landmarks.innerLips?.normalizedPoints, inner.count > 2 {
            let b = inner.bounds
            mouthOpen = clamp(Double(b.height / max(b.width, 0.0001)) * 1.4, 0, 1)
        }

        // Eye aperture: average of both eyes.
        let leftOpen = aperture(of: landmarks.leftEye?.normalizedPoints)
        let rightOpen = aperture(of: landmarks.rightEye?.normalizedPoints)
        let eyeOpen = clamp((leftOpen + rightOpen) / 2 * 3, 0, 1)
        let symmetry = 1 - clamp(abs(leftOpen - rightOpen) * 3, 0, 1)

        return FaceSignals(smile: smile, mouthOpen: mouthOpen, eyeOpen: eyeOpen,
                           symmetry: symmetry, featurePrint: featurePrint, yaw: yaw, pitch: pitch)
    }

    private func aperture(of points: [CGPoint]?) -> Double {
        guard let points, points.count > 2 else { return 0.15 }
        let b = points.bounds
        return Double(b.height / max(b.width, 0.0001))
    }

    private func lightingProfile(brightness: Double, sharpness: Double) -> LightingProfile {
        if brightness < 0.22 { return .lowLight }
        if brightness > 0.82 { return .hardKey }
        if sharpness > 0.5 && (0.35...0.75).contains(brightness) { return .softKey }
        return .even
    }

    // MARK: - Tags & summary

    private func smartTags(classify: [VNClassificationObservation], faceDetected: Bool,
                           lighting: LightingProfile, sharpness: Double) -> [String] {
        var tags: [String] = []
        if faceDetected { tags.append("portrait") }
        tags.append(contentsOf: classify
            .filter { $0.confidence > 0.15 }
            .prefix(4)
            .map { $0.identifier.replacingOccurrences(of: "_", with: " ") })
        tags.append(lighting.rawValue.lowercased())
        if sharpness > 0.6 { tags.append("sharp") }
        // De-duplicate, preserve order, keep it tidy.
        var seen = Set<String>()
        return tags.filter { seen.insert($0).inserted }.prefix(7).map { $0 }
    }

    private func summary(for a: FaceAnalysis) -> String {
        guard a.faceDetected else {
            return "No face was detected in this photo, so face-specific insights are unavailable. Image-quality signals are still shown."
        }
        let quality: String
        switch a.qualityOutOf100 {
        case 80...:  quality = "Excellent capture quality makes this well suited to high-confidence analysis."
        case 60..<80: quality = "Good capture quality overall."
        default:     quality = "Modest capture quality — consider a sharper, better-lit photo for stronger results."
        }
        return "A \(a.sharpnessLabel.lowercased()) \(a.poseLabel.lowercased()) portrait under \(a.lighting.rawValue.lowercased()) lighting. \(quality)"
    }
}
