//
//  LibraryStore.swift
//  Facet
//
//  The user's on-device index of analysed faces. It powers Home statistics,
//  duplicate detection, and "similar faces" clustering — all computed locally
//  from Vision feature prints. Nothing here touches the network.
//

import SwiftUI
import Observation
import Vision

@Observable
@MainActor
final class LibraryStore {

    /// Newest first.
    private(set) var analyses: [FaceAnalysis] = []

    // Similarity thresholds on Vision feature-print distance (lower = more alike).
    private let duplicateThreshold: Float = 0.30
    private let similarThreshold: Float = 0.62

    // MARK: Stats (real counts — honest empty states when the library is new)

    var photosIndexed: Int { analyses.count }
    var clusterCount: Int { computeClusterCount() }

    // MARK: Mutations

    /// Insert a freshly analysed face, computing its duplicate count against the index.
    @discardableResult
    func insert(_ analysis: FaceAnalysis) -> FaceAnalysis {
        var stored = analysis
        stored.duplicateCount = duplicates(of: analysis)
        analyses.insert(stored, at: 0)
        return stored
    }

    /// Erase the entire on-device index (analyses + embeddings).
    func removeAll() {
        analyses.removeAll()
    }

    // MARK: Queries

    /// Faces visually similar to `analysis` already in the library.
    func similar(to analysis: FaceAnalysis) -> [FaceAnalysis] {
        neighbours(of: analysis, within: similarThreshold)
    }

    /// Count of near-identical images (likely duplicates) of `analysis`.
    func duplicates(of analysis: FaceAnalysis) -> Int {
        neighbours(of: analysis, within: duplicateThreshold).count
    }

    // MARK: - Similarity maths (on-device)

    private func neighbours(of analysis: FaceAnalysis, within threshold: Float) -> [FaceAnalysis] {
        guard let query = analysis.featurePrint else { return [] }
        return analyses.filter { other in
            guard other.id != analysis.id, let print = other.featurePrint else { return false }
            var distance: Float = .greatestFiniteMagnitude
            do { try query.computeDistance(&distance, to: print) } catch { return false }
            return distance < threshold
        }
    }

    /// Number of connected components (clusters) in the library under the similar threshold.
    private func computeClusterCount() -> Int {
        let items = analyses
        guard !items.isEmpty else { return 0 }
        var parent = Array(0..<items.count)

        func find(_ x: Int) -> Int {
            var r = x
            while parent[r] != r { parent[r] = parent[parent[r]]; r = parent[r] }
            return r
        }
        func union(_ a: Int, _ b: Int) { parent[find(a)] = find(b) }

        for i in 0..<items.count {
            guard let pi = items[i].featurePrint else { continue }
            for j in (i + 1)..<items.count {
                guard let pj = items[j].featurePrint else { continue }
                var d: Float = .greatestFiniteMagnitude
                if (try? pi.computeDistance(&d, to: pj)) != nil, d < similarThreshold {
                    union(i, j)
                }
            }
        }
        return Set((0..<items.count).map(find)).count
    }
}
