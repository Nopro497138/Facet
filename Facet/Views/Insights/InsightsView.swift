//
//  InsightsView.swift
//  Facet
//
//  Presents every on-device insight for the active analysis: an image-quality
//  gauge, age & mood estimates (clearly labelled), an emotion breakdown, lighting
//  / pose / sharpness / duplicate metrics, smart tags and an AI description.
//  Probabilistic outputs always carry their uncertainty.
//

import SwiftUI

struct InsightsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SettingsStore.self) private var settings

    var body: some View {
        if let analysis = router.activeAnalysis {
            content(analysis)
        } else {
            emptyState
        }
    }

    // MARK: Content

    private func content(_ a: FaceAnalysis) -> some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "On-device AI")
                Text("Insights").font(.facetTitle(26)).foregroundStyle(Palette.text)
            }
            .padding(.top, 4)

            qualityGauge(a)

            if settings.settings.showEstimates {
                estimateRow(a)
                emotionCard(a)
            } else {
                estimatesOffNote
            }

            signalGrid(a)

            SectionHeader(title: "Smart tags")
            tagCloud(a)

            descriptionCard(a)

            PrivacyNote(text: "Every insight above was computed on your device. Estimates such as age and emotion are probabilistic and shown with their uncertainty — never as facts about identity.")
        }
    }

    private func qualityGauge(_ a: FaceAnalysis) -> some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    GaugeRing(progress: a.qualityScore)
                    Text("\(a.qualityOutOf100)").font(.system(size: 20, weight: .bold)).foregroundStyle(Palette.text)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Image quality · \(a.qualityOutOf100) / 100")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(Palette.text)
                    Text(a.summary)
                        .font(.system(size: 12)).foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func estimateRow(_ a: FaceAnalysis) -> some View {
        HStack(spacing: 11) {
            MetricTile(icon: "person.crop.circle", tint: Palette.iris, label: "Age estimate",
                       value: a.age.display, caption: "Estimate · ±\((a.age.upper - a.age.lower) / 2) yrs", estimate: true)
            MetricTile(icon: "face.smiling", tint: Palette.coral, label: "Mood read",
                       value: a.moodLabel, caption: "Low confidence · cue only", estimate: true)
        }
    }

    private func emotionCard(_ a: FaceAnalysis) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 9) {
                    Image(systemName: "heart.text.square")
                        .foregroundStyle(Palette.coral)
                        .frame(width: 30, height: 30)
                        .background(Palette.coral.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text("Emotion estimate — shown cautiously")
                        .font(.system(size: 13)).foregroundStyle(Palette.text2)
                }
                .padding(.bottom, 6)
                ForEach(a.emotions) { EmotionBar(score: $0) }
            }
        }
    }

    private var estimatesOffNote: some View {
        GlassCard {
            HStack(spacing: 11) {
                Image(systemName: "eye.slash").foregroundStyle(Palette.muted)
                Text("Age & emotion estimates are turned off in Settings.")
                    .font(.facetCaption).foregroundStyle(Palette.muted)
            }
        }
    }

    private func signalGrid(_ a: FaceAnalysis) -> some View {
        let columns = [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)]
        return LazyVGrid(columns: columns, spacing: 11) {
            MetricTile(icon: a.lighting.symbol, tint: Palette.aqua, label: "Lighting",
                       value: a.lighting.rawValue, meter: a.brightness)
            MetricTile(icon: "cube", tint: Palette.iris, label: "Head pose",
                       value: a.poseLabel, caption: "yaw \(Int(a.yaw))° · pitch \(Int(a.pitch))°")
            MetricTile(icon: "camera.aperture", tint: Palette.aqua, label: "Blur / sharp",
                       value: a.sharpnessLabel, meter: a.sharpness)
            MetricTile(icon: "square.on.square", tint: Palette.iris, label: "Duplicates",
                       value: "\(a.duplicateCount) found", caption: "in your library")
        }
    }

    private func tagCloud(_ a: FaceAnalysis) -> some View {
        GlassCard {
            FlowLayout(spacing: 8) {
                ForEach(a.tags, id: \.self) { TagChip(text: $0) }
            }
        }
    }

    private func descriptionCard(_ a: FaceAnalysis) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles").font(.system(size: 12))
                    Text("AI DESCRIPTION").font(.system(size: 11, weight: .semibold)).tracking(0.6)
                }
                .foregroundStyle(Palette.iris)
                Text(a.summary)
                    .font(.system(size: 13.5)).foregroundStyle(Palette.text2)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Empty

    private var emptyState: some View {
        ScreenScaffold {
            VStack(spacing: 16) {
                Spacer(minLength: 80)
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Gradients.spectral)
                Text("No insights yet")
                    .font(.facetTitle(22)).foregroundStyle(Palette.text)
                Text("Scan a face and its on-device insights will appear here.")
                    .font(.facetBody).foregroundStyle(Palette.text2).multilineTextAlignment(.center)
                PrimaryButton(title: "Scan a face", systemImage: "viewfinder") { router.go(to: .scan) }
                    .padding(.horizontal, 40).padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Metric tile

private struct MetricTile: View {
    var icon: String
    var tint: Color
    var label: String
    var value: String
    var caption: String? = nil
    var meter: Double? = nil
    var estimate: Bool = false

    var body: some View {
        GlassCard(padding: 15) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 9) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(tint)
                        .frame(width: 30, height: 30)
                        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    Text(label).font(.system(size: 12.5, weight: .medium)).foregroundStyle(Palette.text2)
                }
                .padding(.bottom, 11)

                Text(value)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Palette.text)
                    .lineLimit(1).minimumScaleFactor(0.7)

                if let meter {
                    MeterBar(value: meter).padding(.top, 12)
                } else if let caption {
                    HStack(spacing: 5) {
                        if estimate { Circle().fill(Palette.warn).frame(width: 6, height: 6) }
                        Text(caption).font(.system(size: 11)).foregroundStyle(Palette.faint)
                    }
                    .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
