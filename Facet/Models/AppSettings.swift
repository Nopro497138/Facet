//
//  AppSettings.swift
//  Facet
//
//  Value types backing the Settings screen. The `SettingsStore` manager persists
//  these; views bind to the store.
//

import Foundation

enum AppearanceMode: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case dark = "Dark"
    var id: String { rawValue }
}

enum PerformanceMode: String, CaseIterable, Identifiable {
    case eco = "Eco"
    case max = "Max"
    var id: String { rawValue }

    /// Cap on ambient particle count for the animated background.
    var particleCount: Int { self == .max ? 90 : 36 }
    /// Whether heavy blur / glow effects are enabled.
    var richEffects: Bool { self == .max }
}

/// A snapshot of all user preferences (Codable for persistence).
struct AppSettings: Codable, Equatable {
    var appearance: String = AppearanceMode.dark.rawValue
    var performance: String = PerformanceMode.max.rawValue
    var onDeviceAI: Bool = true
    var showEstimates: Bool = true          // age / emotion estimates
    var neverUploadWithoutConsent: Bool = true
    var reduceMotion: Bool = false

    static let `default` = AppSettings()
}
