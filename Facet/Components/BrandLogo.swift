//
//  BrandLogo.swift
//  Facet
//
//  Renders a connected-service logo from the asset catalog (template SVGs) so it
//  can be tinted. Falls back to a monogram if an asset is missing.
//

import SwiftUI

struct BrandLogo: View {
    var service: ConnectedService
    var tint: Color = .white

    var body: some View {
        Group {
            if UIImage(named: service.id) != nil {
                Image(service.id)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
            } else {
                Text(String(service.name.prefix(1)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(tint)
            }
        }
    }
}

/// A glass tile containing a brand logo, tinted with the brand's glow — used in
/// the Orbit and Results screens.
struct BrandTile: View {
    var service: ConnectedService
    var side: CGFloat = 52

    var body: some View {
        RoundedRectangle(cornerRadius: side * 0.3, style: .continuous)
            .fill(Color(hex: 0x121828).opacity(0.72))
            .overlay {
                RoundedRectangle(cornerRadius: side * 0.3, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            }
            .overlay {
                BrandLogo(service: service)
                    .frame(width: side * 0.46, height: side * 0.46)
            }
            .frame(width: side, height: side)
            .shadow(color: service.brandColor.opacity(0.55), radius: 9)
    }
}
