//
//  Geometry.swift
//  Facet
//
//  Point/rect maths used by the landmark and orbit visualisations.
//

import CoreGraphics
import Foundation

extension CGPoint {
    static func + (l: CGPoint, r: CGPoint) -> CGPoint { CGPoint(x: l.x + r.x, y: l.y + r.y) }
    static func - (l: CGPoint, r: CGPoint) -> CGPoint { CGPoint(x: l.x - r.x, y: l.y - r.y) }
    static func * (p: CGPoint, s: CGFloat) -> CGPoint { CGPoint(x: p.x * s, y: p.y * s) }

    var length: CGFloat { (x * x + y * y).squareRoot() }
    func distance(to other: CGPoint) -> CGFloat { (self - other).length }
}

extension Array where Element == CGPoint {
    /// Centroid of a set of points.
    var centroid: CGPoint {
        guard !isEmpty else { return .zero }
        let sum = reduce(CGPoint.zero, +)
        return CGPoint(x: sum.x / CGFloat(count), y: sum.y / CGFloat(count))
    }

    /// Axis-aligned bounding box of a set of points.
    var bounds: CGRect {
        guard let first else { return .zero }
        var minX = first.x, minY = first.y, maxX = first.x, maxY = first.y
        for p in self {
            minX = Swift.min(minX, p.x); minY = Swift.min(minY, p.y)
            maxX = Swift.max(maxX, p.x); maxY = Swift.max(maxY, p.y)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
