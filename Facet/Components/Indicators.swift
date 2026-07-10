//
//  Indicators.swift
//  Facet
//
//  Data-display atoms: a circular gauge, a horizontal meter, and an emotion bar.
//  Each animates from zero to its value when it appears, so numbers "arrive"
//  rather than pop.
//

import SwiftUI

/// A circular progress gauge with the spectral gradient.
struct GaugeRing: View {
    var progress: Double            // 0…1
    var lineWidth: CGFloat = 9
    var diameter: CGFloat = 84

    @State private var animated: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: animated)
                .stroke(
                    AngularGradient(colors: [Palette.aqua, Palette.iris], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Palette.aqua.opacity(0.5), radius: 6)
        }
        .frame(width: diameter, height: diameter)
        .onAppear {
            withAnimation(reduceMotion ? .none : .easeOut(duration: 1.1)) { animated = progress }
        }
    }
}

/// A thin horizontal meter that fills to `value` (0…1).
struct MeterBar: View {
    var value: Double
    var height: CGFloat = 6
    var gradient: [Color] = [Palette.aqua, Palette.iris]

    @State private var animated: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * animated)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.9)) { animated = clamp(value, 0, 1) }
        }
    }
}

/// A labelled emotion row: name · animated track · percentage.
struct EmotionBar: View {
    var score: EmotionScore

    var body: some View {
        HStack(spacing: 10) {
            Text(score.emotion.rawValue)
                .font(.system(size: 12.5))
                .foregroundStyle(Palette.text2)
                .frame(width: 64, alignment: .leading)
            MeterBar(value: score.value, height: 7)
            Text("\(Int((score.value * 100).rounded()))%")
                .font(.facetMono(12))
                .foregroundStyle(Palette.text2)
                .frame(width: 38, alignment: .trailing)
        }
    }
}
