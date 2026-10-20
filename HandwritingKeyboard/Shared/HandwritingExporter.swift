import UIKit
import PencilKit
import UniformTypeIdentifiers

/// Turns a PencilKit drawing into a picture and puts it on the clipboard.
/// Used by both the main app and the keyboard.
enum HandwritingExporter {

    /// Renders the drawing, cropped to the ink, on a white background.
    static func image(from drawing: PKDrawing, padding: CGFloat = 20) -> UIImage? {
        let inkBounds = drawing.bounds
        guard !inkBounds.isEmpty else { return nil }

        let rect = inkBounds.insetBy(dx: -padding, dy: -padding)

        // Always render in light mode so black ink stays black.
        var ink: UIImage?
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            ink = drawing.image(from: rect, scale: 3)
        }
        guard let ink else { return nil }

        let format = UIGraphicsImageRendererFormat()
        format.scale = ink.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: rect.size))
            ink.draw(in: CGRect(origin: .zero, size: rect.size))
        }
    }

    /// Copies the drawing as a PNG. Returns false if there was nothing to copy.
    @discardableResult
    static func copyToClipboard(_ drawing: PKDrawing) -> Bool {
        guard let png = image(from: drawing)?.pngData() else { return false }
        UIPasteboard.general.setData(png, forPasteboardType: UTType.png.identifier)
        return true
    }
}
