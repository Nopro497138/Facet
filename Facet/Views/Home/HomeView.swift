//
//  HomeView.swift
//  Facet
//
//  The landing stage: the glowing orb hero, real library statistics, primary
//  actions and a list of recently analysed faces. All figures are real counts —
//  the app shows an honest empty state before anything has been analysed.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(LibraryStore.self) private var library

    var body: some View {
        ScreenScaffold {
            header

            GlowOrb()
                .frame(maxWidth: .infinity)
                .frame(height: 260)

            statRow

            VStack(spacing: 11) {
                PrimaryButton(title: "Scan a face", systemImage: "viewfinder") {
                    router.go(to: .scan)
                }
                GhostButton(title: library.analyses.isEmpty ? "Nothing indexed yet" : "Browse indexed library") {
                    if let latest = library.analyses.first {
                        router.activeAnalysis = latest
                        router.go(to: .insights)
                    } else {
                        router.go(to: .scan)
                    }
                }
            }
            .padding(.top, 4)

            recentSection
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: greeting)
                Text("Your face,\nunderstood.")
                    .font(.facetTitle(30))
                    .foregroundStyle(Palette.text)
                    .lineSpacing(0)
            }
            Spacer()
            AppIconMark(size: 42)
        }
        .padding(.top, 4)
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            StatCard(value: "\(library.photosIndexed)", label: "Faces indexed")
            StatCard(value: "\(library.clusterCount)", label: "Clusters")
            StatCard(value: "100%", label: "On device")
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent",
                          actionTitle: library.analyses.isEmpty ? nil : "See all",
                          action: library.analyses.isEmpty ? nil : {
                if let latest = library.analyses.first {
                    router.activeAnalysis = latest
                    router.go(to: .insights)
                }
            })

            if library.analyses.isEmpty {
                emptyRecent
            } else {
                ForEach(library.analyses.prefix(4)) { analysis in
                    RecentRow(analysis: analysis) {
                        router.activeAnalysis = analysis
                        router.go(to: .insights)
                    }
                }
            }
        }
        .padding(.top, 6)
    }

    private var emptyRecent: some View {
        GlassCard {
            HStack(spacing: 13) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.aqua)
                    .frame(width: 44, height: 44)
                    .background(Palette.aqua.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text("No analyses yet").font(.system(size: 15, weight: .semibold))
                    Text("Scan a face to see insights appear here.")
                        .font(.facetCaption).foregroundStyle(Palette.muted)
                }
            }
        }
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Welcome back"
        }
    }
}

// MARK: - Pieces

private struct StatCard: View {
    var value: String
    var label: String
    var body: some View {
        GlassCard(padding: 13) {
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.facetMono(22, weight: .semibold))
                    .foregroundStyle(Gradients.spectral)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Palette.muted)
            }
        }
    }
}

private struct RecentRow: View {
    var analysis: FaceAnalysis
    var action: () -> Void

    var body: some View {
        Button(action: { Haptics.tap(); action() }) {
            HStack(spacing: 12) {
                FaceSubjectView(image: analysis.image, showMesh: analysis.image == nil)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Face · \(analysis.createdAt.relativeShort)")
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(Palette.text)
                    Text("\(analysis.tags.count) tags · \(analysis.poseLabel)")
                        .font(.facetCaption).foregroundStyle(Palette.muted)
                }
                Spacer()
                Badge(text: "Q\(analysis.qualityOutOf100)")
            }
            .padding(13)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}
