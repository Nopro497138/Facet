//
//  ScanViewModel.swift
//  Facet
//
//  Coordinates the scan experience: it runs the real Vision analysis while a
//  scripted, cinematic staging sequence plays, then reveals the finished
//  `FaceAnalysis`. The analysis and the animation run concurrently so the UI is
//  never blocked.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ScanViewModel {

    enum Phase: Equatable {
        case idle          // waiting for the user to pick a photo
        case scanning
        case done
        case failed(String)
    }

    private(set) var phase: Phase = .idle
    private(set) var progress: Double = 0
    private(set) var statusMessage = "Ready"
    private(set) var activeStep = 0            // 0…3 while running, 4 when complete
    private(set) var selectedImage: UIImage?
    private(set) var analysis: FaceAnalysis?

    /// Titles shown in the step checklist.
    let stepTitles = [
        "Detect & align face",
        "Build 3D depth mesh",
        "Map 68 landmarks",
        "Extract quality signals"
    ]

    private let stageMessages = [
        "Locating facial landmarks…",
        "Reconstructing 3D depth mesh…",
        "Sampling 68 keypoints…",
        "Scoring image quality…"
    ]

    func reset() {
        phase = .idle; progress = 0; activeStep = 0
        statusMessage = "Ready"; selectedImage = nil; analysis = nil
    }

    /// Begin analysing a user-chosen photo.
    func startScan(with image: UIImage, into library: LibraryStore, reduceMotion: Bool) async {
        selectedImage = image
        phase = .scanning
        progress = 0
        activeStep = 0
        analysis = nil

        // Kick off the real analysis immediately.
        async let analysisResult = FaceAnalysisService.shared.analyze(image)

        // Play the staged reveal in parallel.
        await runStaging(reduceMotion: reduceMotion)

        do {
            let result = try await analysisResult
            let stored = library.insert(result)          // computes duplicate count too
            withAnimation(Motion.card) {
                analysis = stored
                progress = 1
                activeStep = 4
                statusMessage = stored.faceDetected ? "Analysis complete." : "No face detected."
                phase = .done
            }
            Haptics.success()
        } catch {
            withAnimation(Motion.card) {
                statusMessage = error.localizedDescription
                phase = .failed(error.localizedDescription)
            }
        }
    }

    private func runStaging(reduceMotion: Bool) async {
        let targets: [(progress: Double, step: Int)] = [(0.22, 0), (0.52, 1), (0.78, 2), (0.96, 3)]
        for (index, target) in targets.enumerated() {
            if !reduceMotion { try? await Task.sleep(for: .milliseconds(650)) }
            withAnimation(Motion.panel) {
                progress = target.progress
                activeStep = target.step
                statusMessage = stageMessages[index]
            }
            Haptics.tick()
        }
    }
}
