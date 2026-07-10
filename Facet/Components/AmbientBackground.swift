//
//  AmbientBackground.swift
//  Facet
//
//  The full-screen backdrop shared by every stage: a graphite base, soft
//  spectral glows, a faint sensor grid, and the ambient particle field.
//

import SwiftUI

struct AmbientBackground: View {
    var particleCount: Int

    var body: some View {
        ZStack {
            Gradients.appBackground.ignoresSafeArea()

            // Soft spectral glows.
            Circle()
                .fill(Palette.aqua.opacity(0.12))
                .frame(width: 520, height: 520)
                .blur(radius: 120)
                .offset(x: -140, y: -260)
            Circle()
                .fill(Palette.iris.opacity(0.16))
                .frame(width: 560, height: 560)
                .blur(radius: 130)
                .offset(x: 150, y: -120)
            Circle()
                .fill(Palette.irisDeep.opacity(0.12))
                .frame(width: 520, height: 520)
                .blur(radius: 130)
                .offset(x: 60, y: 420)

            ParticleField(count: particleCount)
        }
        .ignoresSafeArea()
    }
}
