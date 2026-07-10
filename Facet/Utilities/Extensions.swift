//
//  Extensions.swift
//  Facet
//
//  Small, focused helpers shared across the app.
//

import SwiftUI
import ImageIO

// MARK: - Numeric helpers

@inline(__always)
func clamp<T: Comparable>(_ value: T, _ lower: T, _ upper: T) -> T {
    min(max(value, lower), upper)
}

extension Double {
    /// Linear map from one range to another, clamped to the output range.
    func mapped(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
        guard from.upperBound != from.lowerBound else { return to.lowerBound }
        let t = (self - from.lowerBound) / (from.upperBound - from.lowerBound)
        return clamp(to.lowerBound + t * (to.upperBound - to.lowerBound), to.lowerBound, to.upperBound)
    }
}

// MARK: - Orientation bridging

extension CGImagePropertyOrientation {
    /// Bridge a `UIImage.Orientation` to the Core Graphics orientation Vision expects.
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:            self = .up
        case .down:          self = .down
        case .left:          self = .left
        case .right:         self = .right
        case .upMirrored:    self = .upMirrored
        case .downMirrored:  self = .downMirrored
        case .leftMirrored:  self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:    self = .up
        }
    }
}

// MARK: - Date

extension Date {
    var relativeShort: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: self, relativeTo: .now)
    }
}

// MARK: - View helpers

extension View {
    /// Applies a transform only when a condition is met (keeps view builders tidy).
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}
