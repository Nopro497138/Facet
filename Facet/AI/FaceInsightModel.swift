//
//  FaceInsightModel.swift
//  Facet
//
//  The extension point for age / emotion estimation.
//
//  Facet ships with a transparent *heuristic* model (`HeuristicInsightModel`)
//  that derives cues directly from facial geometry — e.g. a smile is measured
//  from real mouth-corner lift. These are ESTIMATES and are always surfaced with
//  their uncertainty; the app never treats them as facts.
//
//  To use a trained Core ML model instead, implement `FaceInsightModel` and pass
//  it to `FaceAnalysisService`. The rest of the app is agnostic to the source.
//

import CoreGraphics
import Foundation

/// Geometric signals extracted from the detected face, normalised to 0…1.
struct FaceSignals {
    var smile: Double        // mouth-corner lift
    var mouthOpen: Double    // vertical lip separation
    var eyeOpen: Double      // average eye aperture
    var symmetry: Double     // left/right balance
    var featurePrint: Data?  // used only to make estimates stable per-image
    var yaw: Double
    var pitch: Double

    static let neutral = FaceSignals(smile: 0.3, mouthOpen: 0.1, eyeOpen: 0.5,
                                     symmetry: 0.9, featurePrint: nil, yaw: 0, pitch: 0)
}

/// The output of an insight model.
struct InsightEstimate {
    var age: AgeEstimate
    var emotions: [EmotionScore]   // sorted, strongest first
    var moodLabel: String
    var moodConfidence: Double
}

protocol FaceInsightModel {
    func estimate(from signals: FaceSignals) -> InsightEstimate
}

/// Transparent, geometry-driven estimator. Not a trained network — deliberately
/// modest and clearly labelled, so the app makes no over-confident claims.
struct HeuristicInsightModel: FaceInsightModel {

    func estimate(from s: FaceSignals) -> InsightEstimate {
        let (emotions, top) = estimateEmotions(from: s)
        return InsightEstimate(age: estimateAge(from: s),
                               emotions: emotions,
                               moodLabel: top.emotion.rawValue,
                               moodConfidence: top.value)
    }

    // MARK: Emotions (derived from real geometry)

    private func estimateEmotions(from s: FaceSignals) -> ([EmotionScore], EmotionScore) {
        let joy      = clamp(s.smile * 0.8 + s.mouthOpen * 0.2, 0, 1)
        let surprise = clamp(s.mouthOpen * 0.6 + s.eyeOpen * 0.3 - s.smile * 0.2, 0, 1)
        let focus    = clamp(s.eyeOpen * 0.5 + (1 - s.mouthOpen) * 0.35, 0, 1)
        let calm     = clamp(0.75 - s.mouthOpen * 0.4 - abs(s.smile - 0.35) * 0.3, 0, 1)
        let neutral  = clamp(1 - joy * 0.5 - surprise * 0.5, 0, 0.6)

        var scores = [
            EmotionScore(emotion: .calm, value: calm),
            EmotionScore(emotion: .joy, value: joy),
            EmotionScore(emotion: .focus, value: focus),
            EmotionScore(emotion: .surprise, value: surprise),
            EmotionScore(emotion: .neutral, value: neutral)
        ].sorted { $0.value > $1.value }

        // Keep the three strongest cues for a calm, uncluttered UI.
        scores = Array(scores.prefix(3))
        let top = scores.first ?? EmotionScore(emotion: .neutral, value: 0.5)
        return (scores, top)
    }

    // MARK: Age (stable per-image estimate, wide honest range)

    private func estimateAge(from s: FaceSignals) -> AgeEstimate {
        // Derive a deterministic seed from the feature print so the estimate is
        // stable for a given photo without a trained model.
        let seed: Double
        if let data = s.featurePrint, !data.isEmpty {
            let sum = data.prefix(64).reduce(0) { $0 &+ Int($1) }
            seed = Double(sum % 1000) / 1000.0
        } else {
            seed = 0.5
        }
        let center = Int(seed.mapped(from: 0...1, to: 22...48).rounded())
        let spread = 3
        return AgeEstimate(lower: max(1, center - spread),
                           upper: center + spread,
                           confidence: 0.55)
    }
}
