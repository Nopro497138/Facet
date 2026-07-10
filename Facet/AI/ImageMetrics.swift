//
//  ImageMetrics.swift
//  Facet
//
//  Core Image measurements for exposure and sharpness. These feed the "Image
//  quality", "Lighting" and "Blur / sharp" insights. All work runs on-device.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

final class ImageMetrics {
    static let shared = ImageMetrics()

    private let context = CIContext(options: [.workingColorSpace: NSNull()])
    private let deviceRGB = CGColorSpaceCreateDeviceRGB()

    /// Mean relative luminance of the image (0 = black, 1 = white).
    func brightness(of cgImage: CGImage) -> Double {
        let ci = CIImage(cgImage: cgImage)
        guard let rgba = averagePixel(of: ci, extent: ci.extent) else { return 0.5 }
        return luminance(rgba)
    }

    /// A 0…1 sharpness score derived from average edge energy. Higher is crisper.
    func sharpness(of cgImage: CGImage) -> Double {
        let ci = CIImage(cgImage: cgImage)
        let edges = ci.applyingFilter("CIEdges", parameters: [kCIInputIntensityKey: 8.0])
        guard let rgba = averagePixel(of: edges, extent: ci.extent) else { return 0.5 }
        // Edge luminance is small; scale into a perceptual 0…1 range (tuned empirically).
        return clamp(luminance(rgba) * 6.0, 0, 1)
    }

    // MARK: - Private

    private func averagePixel(of image: CIImage, extent: CGRect) -> (Double, Double, Double)? {
        let params: [String: Any] = [
            kCIInputImageKey: image,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ]
        guard let output = CIFilter(name: "CIAreaAverage", parameters: params)?.outputImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: deviceRGB)
        return (Double(bitmap[0]) / 255, Double(bitmap[1]) / 255, Double(bitmap[2]) / 255)
    }

    private func luminance(_ rgb: (Double, Double, Double)) -> Double {
        0.2126 * rgb.0 + 0.7152 * rgb.1 + 0.0722 * rgb.2
    }
}
