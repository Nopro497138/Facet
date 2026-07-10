//
//  AppRouter.swift
//  Facet
//
//  Lightweight, observable navigation coordinator. Rather than a stack-based
//  NavigationPath, Facet is a small set of full-screen "stages" that cross-fade
//  into one another, so a single enum + observable object is the cleanest model.
//

import SwiftUI
import Observation

/// Every full-screen destination in the app.
enum Screen: String, CaseIterable, Identifiable, Hashable {
    case home, scan, orbit, insights, search, results, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:     return "Home"
        case .scan:     return "Scan"
        case .orbit:    return "Sources"
        case .insights: return "Insights"
        case .search:   return "Search"
        case .results:  return "Results"
        case .settings: return "Settings"
        }
    }

    /// SF Symbol used in the tab bar / chrome.
    var symbol: String {
        switch self {
        case .home:     return "house.fill"
        case .scan:     return "viewfinder"
        case .orbit:    return "circle.hexagongrid.fill"
        case .insights: return "chart.bar.xaxis"
        case .search:   return "magnifyingglass"
        case .results:  return "square.grid.2x2.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@Observable
@MainActor
final class AppRouter {

    /// The stage currently on screen.
    private(set) var screen: Screen = .home

    /// The direction of the last transition, so the container can animate
    /// forward vs. backward moves differently.
    private(set) var goingForward = true

    /// The analysis currently being explored across Scan → Insights → Orbit → Results.
    var activeAnalysis: FaceAnalysis?

    /// The most recent authorized-source search results, surfaced on the Results stage.
    var searchResults: [SearchResult] = []

    /// Ordered flow used to infer transition direction.
    private let flow: [Screen] = [.home, .scan, .insights, .orbit, .search, .results, .settings]

    /// Move to a stage with an inferred, animated transition.
    func go(to destination: Screen) {
        guard destination != screen else { return }
        let from = flow.firstIndex(of: screen) ?? 0
        let to = flow.firstIndex(of: destination) ?? 0
        goingForward = to >= from
        withAnimation(Motion.stage) {
            screen = destination
        }
    }
}
