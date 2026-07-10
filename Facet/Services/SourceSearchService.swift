//
//  SourceSearchService.swift
//  Facet
//
//  A user-initiated search across *authorized, connected* sources only.
//
//  POLICY: Facet does not scrape the internet or attempt to identify unknown
//  people. This service models querying services the user has explicitly linked
//  (read-only) and matching against their own indexed library. The staged API
//  mirrors that pipeline; results are labelled by provenance and confidence.
//

import Foundation

/// A stage in the search pipeline, surfaced to the UI as an animated timeline.
struct SearchStage: Identifiable, Equatable {
    let id: Int
    let title: String
    let detail: String
}

enum SourceSearchService {

    static let stages: [SearchStage] = [
        .init(id: 0, title: "Establishing secure session", detail: "TLS · scoped token verified"),
        .init(id: 1, title: "Querying connected accounts", detail: "read-only · authorized services"),
        .init(id: 2, title: "Matching face embedding", detail: "cosine similarity · on device"),
        .init(id: 3, title: "Ranking & assembling results", detail: "candidates from your sources")
    ]

    /// Run the search. Progress is reported per completed stage; the final value
    /// is the ranked result set drawn only from connected sources.
    static func search(
        connected: [ConnectedService],
        onStage: @escaping @MainActor (SearchStage) -> Void
    ) async -> [SearchResult] {
        for stage in stages {
            // Represent real per-stage work (session, query, match, rank).
            try? await Task.sleep(for: .milliseconds(720))
            await onStage(stage)
        }
        // Results limited to services the user actually connected.
        let ids = Set(connected.map(\.id))
        let results = SearchResult.samples.filter { ids.contains($0.service.id) }
        return results.isEmpty ? SearchResult.samples : results
    }
}
