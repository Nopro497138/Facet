//
//  SettingsStore.swift
//  Facet
//
//  Observable, persisted user preferences. Views bind directly to `settings`;
//  every change is written to `UserDefaults` as JSON.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class SettingsStore {

    private let key = "facet.settings.v1"

    var settings: AppSettings {
        didSet { persist() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
    }

    // Convenience typed accessors (non-persisted derivations).
    var performanceMode: PerformanceMode { PerformanceMode(rawValue: settings.performance) ?? .max }
    var appearanceMode: AppearanceMode { AppearanceMode(rawValue: settings.appearance) ?? .dark }

    /// Effective particle budget for the animated background.
    var particleBudget: Int { settings.reduceMotion ? 0 : performanceMode.particleCount }

    private func persist() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
