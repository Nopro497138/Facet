//
//  Haptics.swift
//  Facet
//
//  A thin wrapper over UIKit's feedback generators so micro-interactions can
//  add tactile feedback with a single call. Prepared generators reduce latency.
//

import UIKit

@MainActor
enum Haptics {
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactSoft  = UIImpactFeedbackGenerator(style: .soft)
    private static let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let selection   = UISelectionFeedbackGenerator()
    private static let notify      = UINotificationFeedbackGenerator()

    /// A light tap for taps on chips, toggles and secondary controls.
    static func tap() {
        impactLight.prepare()
        impactLight.impactOccurred()
    }

    /// A softer, weightier press for primary buttons.
    static func press() {
        impactSoft.prepare()
        impactSoft.impactOccurred(intensity: 0.8)
    }

    /// A crisp tick used as scan/search stages complete.
    static func tick() {
        impactRigid.prepare()
        impactRigid.impactOccurred(intensity: 0.6)
    }

    /// Selection change (segmented controls, tab switches).
    static func change() {
        selection.prepare()
        selection.selectionChanged()
    }

    /// Success feedback when an analysis or search finishes.
    static func success() {
        notify.prepare()
        notify.notificationOccurred(.success)
    }
}
