//
//  SearchView.swift
//  Facet
//
//  The user-initiated search across authorized sources. A pulsing neural core, an
//  animated pipeline timeline and a live progress bar keep the UI alive while the
//  staged search runs — the UI never freezes.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var vm = SearchViewModel()

    var body: some View {
        ScreenScaffold {
            hero
            timeline
            progressCard
            if vm.finished { resultsButton }
        }
        .task {
            if !vm.finished && !vm.isSearching {
                await vm.run(connected: ConnectedService.connected)
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 8) {
            Eyebrow(text: "Authorized sources only")
            Text(vm.finished ? "Search complete" : "Searching…")
                .font(.facetTitle(25)).foregroundStyle(Palette.text)
            pulseCore.padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var pulseCore: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    let phase = ((t / 2.4) + Double(i) / 3).truncatingRemainder(dividingBy: 1)
                    Circle()
                        .strokeBorder(Palette.aqua.opacity(0.5), lineWidth: 1)
                        .scaleEffect(0.4 + phase * 0.75)
                        .opacity((1 - phase) * 0.8)
                }
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: 0xB8FFF0), Palette.aqua, Palette.iris],
                                         center: UnitPoint(x: 0.4, y: 0.35), startRadius: 1, endRadius: 40))
                    .frame(width: 46, height: 46)
                    .scaleEffect(1 + (reduceMotion ? 0 : sin(t * 3) * 0.06))
                    .shadow(color: Palette.aqua.opacity(0.6), radius: 20)
            }
            .frame(width: 120, height: 120)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(vm.stages) { stage in
                let state = vm.stageState(stage.id)
                TimelineRow(stage: stage,
                            done: state.done,
                            active: state.active,
                            isLast: stage.id == vm.stages.count - 1)
            }
        }
    }

    private var progressCard: some View {
        GlassCard(padding: 14) {
            HStack(spacing: 12) {
                Text("\(Int(vm.progress * 100))%")
                    .font(.facetMono(12)).foregroundStyle(Palette.aqua)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08))
                        Capsule().fill(Gradients.spectral).frame(width: geo.size.width * vm.progress)
                    }
                }
                .frame(height: 5)
                .animation(Motion.panel, value: vm.progress)
            }
        }
    }

    private var resultsButton: some View {
        PrimaryButton(title: "Show \(vm.results.count) results", systemImage: "arrow.right") {
            router.searchResults = vm.results
            router.go(to: .results)
        }
        .revealOnAppear()
    }
}

// MARK: - Timeline row

private struct TimelineRow: View {
    var stage: SearchStage
    var done: Bool
    var active: Bool
    var isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(LinearGradient(colors: [Palette.aqua, .clear], startPoint: .top, endPoint: .bottom))
                        .frame(width: 2)
                        .offset(y: 26)
                }
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x121828))
                        .overlay(Circle().strokeBorder(done || active ? Palette.aqua : Palette.hairline, lineWidth: 1))
                        .frame(width: 26, height: 26)
                        .shadow(color: (done || active) ? Palette.aqua.opacity(0.5) : .clear, radius: 8)
                    if done {
                        Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(Palette.aqua)
                    } else if active {
                        Circle().fill(Palette.aqua).frame(width: 8, height: 8)
                    }
                }
                .frame(width: 26, height: 26)
            }
            .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(done || active ? Palette.text : Palette.faint)
                if done || active {
                    Text(stage.detail)
                        .font(.facetMono(12)).foregroundStyle(Palette.muted)
                        .transition(.opacity)
                }
            }
            .padding(.bottom, 16)
            Spacer()
        }
        .animation(Motion.panel, value: done)
        .animation(Motion.panel, value: active)
    }
}
