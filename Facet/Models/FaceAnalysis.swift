//
//  FaceAnalysis.swift
//  Facet
//
//  The core value type produced by the on-device analysis pipeline. Every field
//  is derived locally with the Vision framework or clearly-labelled heuristics.
//  Probabilistic fields (age, emotion) always carry their uncertainty.
//

import UIKit
import CoreGraphics
import Vision

// MARK: - Estimates

/// An age *estimate*, expressed as a range with a confidence. Never a fact.
struct AgeEstimate: Hashable {
    var lower: Int
    var upper: Int
    var confidence: Double        // 0…1
    var display: String { "\(lower)–\(upper)" }
    static let unknown = AgeEstimate(lower: 0, upper: 0, confidence: 0)
}

enum Emotion: String, CaseIterable, Identifiable, Hashable {
    case calm = "Calm"
    case joy = "Joy"
    case focus = "Focus"
    case surprise = "Surprise"
    case neutral = "Neutral"
    var id: String { rawValue }
}

/// A single emotion cue with an intensity 0…1. Presented cautiously.
struct EmotionScore: Identifiable, Hashable {
    var id: String { emotion.rawValue }
    var emotion: Emotion
    var value: Double
}

/// A qualitative read of the light on the subject.
enum LightingProfile: String, Hashable {
    case softKey  = "Soft key"
    case hardKey  = "Hard key"
    case even     = "Even"
    case lowLight = "Low light"
    case backlit  = "Backlit"

    var symbol: String {
        switch self {
        case .softKey:  return "sun.max"
        case .hardKey:  return "sun.max.fill"
        case .even:     return "circle.lefthalf.filled"
        case .lowLight: return "moon.stars"
        case .backlit:  return "sun.haze"
        }
    }
}

// MARK: - FaceAnalysis

struct FaceAnalysis: Identifiable {
    let id: UUID
    var image: UIImage
    var createdAt: Date

    /// Whether a face was actually detected. When false the UI degrades gracefully.
    var faceDetected: Bool

    // Geometry — all normalised to the image (0…1, top-left origin).
    var faceBoundingBox: CGRect
    var landmarks: [CGPoint]

    // Pose (degrees).
    var roll: Double
    var yaw: Double
    var pitch: Double

    // Quality signals (0…1).
    var qualityScore: Double
    var sharpness: Double
    var brightness: Double
    var lighting: LightingProfile

    // Estimates.
    var age: AgeEstimate
    var emotions: [EmotionScore]   // sorted, strongest first
    var moodLabel: String
    var moodConfidence: Double

    // Semantics.
    var tags: [String]
    var summary: String

    // Similarity / de-duplication (on-device Vision feature print).
    var featurePrint: VNFeaturePrintObservation?
    var duplicateCount: Int

    // MARK: Derived display helpers

    var qualityOutOf100: Int { Int((qualityScore * 100).rounded()) }
    var sharpnessLabel: String { sharpness > 0.6 ? "Sharp" : (sharpness > 0.35 ? "Soft" : "Blurred") }

    var poseLabel: String {
        if abs(yaw) < 12 && abs(pitch) < 12 { return "Frontal" }
        if yaw <= -12 { return "Turned left" }
        if yaw >= 12 { return "Turned right" }
        return pitch > 0 ? "Looking up" : "Looking down"
    }

    var topEmotion: EmotionScore? { emotions.first }

    init(
        id: UUID = UUID(),
        image: UIImage,
        createdAt: Date = .now,
        faceDetected: Bool = true,
        faceBoundingBox: CGRect = CGRect(x: 0.25, y: 0.2, width: 0.5, height: 0.6),
        landmarks: [CGPoint] = [],
        roll: Double = 0, yaw: Double = 0, pitch: Double = 0,
        qualityScore: Double = 0, sharpness: Double = 0, brightness: Double = 0,
        lighting: LightingProfile = .even,
        age: AgeEstimate = .unknown,
        emotions: [EmotionScore] = [],
        moodLabel: String = "Neutral", moodConfidence: Double = 0,
        tags: [String] = [], summary: String = "",
        featurePrint: VNFeaturePrintObservation? = nil, duplicateCount: Int = 0
    ) {
        self.id = id
        self.image = image
        self.createdAt = createdAt
        self.faceDetected = faceDetected
        self.faceBoundingBox = faceBoundingBox
        self.landmarks = landmarks
        self.roll = roll; self.yaw = yaw; self.pitch = pitch
        self.qualityScore = qualityScore; self.sharpness = sharpness; self.brightness = brightness
        self.lighting = lighting
        self.age = age; self.emotions = emotions
        self.moodLabel = moodLabel; self.moodConfidence = moodConfidence
        self.tags = tags; self.summary = summary
        self.featurePrint = featurePrint; self.duplicateCount = duplicateCount
    }
}
