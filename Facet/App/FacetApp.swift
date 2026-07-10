//
//  FacetApp.swift
//  Facet — Face Intelligence
//
//  The application entry point. Facet is a privacy-first face-analysis app:
//  every insight is computed on-device with the Vision framework, and photos
//  never leave the device without an explicit user action.
//
//  Architecture: SwiftUI + MVVM + Swift Concurrency. Global app state is
//  injected through the SwiftUI `Environment` using the Observation framework
//  (`@Observable`), keeping views declarative and testable.
//

import SwiftUI

@main
struct FacetApp: App {

    /// Drives which screen is on-stage and holds the active analysis.
    @State private var router = AppRouter()

    /// User preferences (appearance, AI, privacy, performance) persisted to disk.
    @State private var settings = SettingsStore()

    /// The on-device index of analyzed faces used for clustering & search.
    @State private var library = LibraryStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(settings)
                .environment(library)
                .preferredColorScheme(.dark)          // Facet commits to a dark biometric console
                .tint(Palette.aqua)
                .statusBarHidden(false)
        }
    }
}
