//
//  Sources.swift
//  Facet
//
//  Models for user-connected services and the results returned from them.
//
//  IMPORTANT (policy): these represent services the user has *connected and
//  authorized*. Facet never claims to identify unknown people or search the open
//  internet. Search runs only against sources the user has explicitly enabled.
//

import SwiftUI

/// A service the user can connect (read-only) as an authorized search source.
struct ConnectedService: Identifiable, Hashable {
    let id: String        // stable key, also the asset-catalog image name
    var name: String
    var brandHex: UInt
    var isConnected: Bool

    var brandColor: Color { Color(hex: brandHex) }

    static let catalog: [ConnectedService] = [
        .init(id: "instagram", name: "Instagram", brandHex: 0xE4405F, isConnected: true),
        .init(id: "facebook",  name: "Facebook",  brandHex: 0x1877F2, isConnected: true),
        .init(id: "tiktok",    name: "TikTok",    brandHex: 0xFE2C55, isConnected: false),
        .init(id: "linkedin",  name: "LinkedIn",  brandHex: 0x0A66C2, isConnected: true),
        .init(id: "x",         name: "X",         brandHex: 0xBFC6D4, isConnected: true),
        .init(id: "reddit",    name: "Reddit",    brandHex: 0xFF4500, isConnected: false),
        .init(id: "github",    name: "GitHub",    brandHex: 0xBFC6D4, isConnected: false),
        .init(id: "threads",   name: "Threads",   brandHex: 0xBFC6D4, isConnected: false),
        .init(id: "pinterest", name: "Pinterest", brandHex: 0xE60023, isConnected: false),
        .init(id: "youtube",   name: "YouTube",   brandHex: 0xFF0000, isConnected: false),
        .init(id: "discord",   name: "Discord",   brandHex: 0x5865F2, isConnected: false)
    ]

    static var connected: [ConnectedService] { catalog.filter(\.isConnected) }
}

/// How a result was obtained — used to label confidence honestly.
enum ResultProvenance: Hashable {
    /// Visual similarity within an authorized source (carries a 0…1 score).
    case similarity(Double)
    /// The user themselves supplied / owns this item (no "match" claim).
    case userProvided

    var confidenceText: String? {
        switch self {
        case .similarity(let s): return "\(Int((s * 100).rounded()))% match"
        case .userProvided:      return "Source: you"
        }
    }
}

/// A single search result card.
struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    var service: ConnectedService
    var detail: String       // e.g. "@your.handle", "Profile photo"
    var date: String
    var dimensions: String?
    var provenance: ResultProvenance

    static let samples: [SearchResult] = [
        .init(service: .catalog[1], detail: "Your account", date: "Mar 2024", dimensions: "1080×1080", provenance: .similarity(0.94)),
        .init(service: .catalog[0], detail: "@your.handle", date: "Jan 2024", dimensions: "Post",      provenance: .similarity(0.91)),
        .init(service: .catalog[3], detail: "Profile photo", date: "2023",    dimensions: "400×400",   provenance: .similarity(0.78)),
        .init(service: .catalog[4], detail: "Header crop",  date: "2023",     dimensions: nil,          provenance: .userProvided),
        .init(service: .catalog[1], detail: "Tagged photo", date: "Dec 2023", dimensions: "1440×1440", provenance: .similarity(0.71)),
        .init(service: .catalog[3], detail: "Article byline", date: "2022",   dimensions: nil,          provenance: .similarity(0.66))
    ]
}
