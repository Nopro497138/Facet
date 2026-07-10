//
//  SearchViewModel.swift
//  Facet
//
//  Drives the authorized-source search: an animated pipeline of stages that
//  resolves to a ranked, provenance-labelled result set. See SourceSearchService
//  for the policy notes — this only ever queries services the user connected.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class SearchViewModel {

    let stages = SourceSearchService.stages

    private(set) var completedStages: Set<Int> = []
    private(set) var activeStage: Int = -1
    private(set) var progress: Double = 0
    private(set) var isSearching = false
    private(set) var finished = false
    private(set) var results: [SearchResult] = []

    func stageState(_ id: Int) -> (done: Bool, active: Bool) {
        (completedStages.contains(id), id == activeStage && !completedStages.contains(id))
    }

    func run(connected: [ConnectedService]) async {
        guard !isSearching else { return }
        isSearching = true
        finished = false
        progress = 0
        activeStage = -1
        completedStages = []
        results = []

        let output = await SourceSearchService.search(connected: connected) { [weak self] stage in
            guard let self else { return }
            withAnimation(Motion.panel) {
                for i in 0..<stage.id { self.completedStages.insert(i) }
                self.activeStage = stage.id
                self.progress = Double(stage.id + 1) / Double(self.stages.count)
            }
            Haptics.tick()
        }

        withAnimation(Motion.card) {
            completedStages = Set(stages.map(\.id))
            activeStage = -1
            results = output
            progress = 1
            isSearching = false
            finished = true
        }
        Haptics.success()
    }
}
