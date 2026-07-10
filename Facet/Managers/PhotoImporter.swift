//
//  PhotoImporter.swift
//  Facet
//
//  Bridges a `PhotosPickerItem` (chosen explicitly by the user) into a `UIImage`.
//  This is the only path by which a photo enters Facet, keeping the privacy model
//  simple: the user picks, then analysis runs on-device.
//

import SwiftUI
import PhotosUI
import UIKit

enum PhotoImporter {
    /// Load the user-selected photo as a `UIImage`, downscaling very large images
    /// to keep analysis fast and memory low.
    static func load(_ item: PhotosPickerItem) async -> UIImage? {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return nil }
        return downscaled(image, maxDimension: 1600)
    }

    private static func downscaled(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }
        let scale = maxDimension / longest
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
