//
//  ResultsView.swift
//  Facet
//
//  The search results. Glass cards stagger into view, each showing the source,
//  a confidence/provenance chip, thumbnail, date and metadata, and an Open
//  affordance. Confidence is only shown where it is technically appropriate.
//

import SwiftUI

struct ResultsView: View {
    @Environment(AppRouter.self) private var router

    private var results: [SearchResult] {
        router.searchResults.isEmpty ? SearchResult.samples : router.searchResults
    }

    var body: some View {
        ScreenScaffold {
            header
            ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                ResultCard(result: result)
                    .revealOnAppear(delay: Double(index) * 0.06)
            }
            PrivacyNote(
                symbol: "info.circle",
                text: "Results come only from services you connected and authorized. Confidence reflects visual similarity within those sources — not a claim about anyone's identity."
            )
            .revealOnAppear(delay: Double(results.count) * 0.06)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "From your sources")
                Text("\(results.count) matches").font(.facetTitle(26)).foregroundStyle(Palette.text)
            }
            Spacer()
            Badge(text: "Read-only")
        }
        .padding(.top, 4)
    }
}

// MARK: - Result card

private struct ResultCard: View {
    var result: SearchResult

    var body: some View {
        Button {
            Haptics.tap()
            // A real integration would deep-link into the connected service the
            // user authorized. There is no open-web lookup.
        } label: {
            HStack(spacing: 13) {
                thumbnail
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(result.service.name).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(Palette.text)
                        ConfidenceChip(provenance: result.provenance)
                    }
                    metadata
                }
                Spacer(minLength: 6)
                openButton
            }
            .padding(13)
            .glassCard()
        }
        .buttonStyle(CardButtonStyle())
    }

    private var thumbnail: some View {
        FaceSubjectView(showMesh: true)
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
            .overlay(alignment: .bottomTrailing) {
                BrandLogo(service: result.service)
                    .frame(width: 14, height: 14)
                    .padding(6)
                    .background(result.service.brandColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color(hex: 0x0B0F1A), lineWidth: 2))
                    .offset(x: 6, y: 6)
            }
    }

    private var metadata: some View {
        HStack(spacing: 8) {
            Text(result.detail)
            Text("·")
            Text(result.date)
            if let dims = result.dimensions {
                Text("·"); Text(dims)
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(Palette.muted)
        .lineLimit(1)
    }

    private var openButton: some View {
        Image(systemName: "arrow.up.forward")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Palette.text2)
            .frame(width: 34, height: 34)
            .glassCard(cornerRadius: 11, highlight: false)
    }
}
