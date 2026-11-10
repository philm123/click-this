import AppKit
import BigArrowCore

/// The Drop look's sign: compressed black caps on a square sign with a thick ink edge. The hard
/// shadow is the overlay's (see `OverlayLayers`), so sign and arrow cast one shadow.
extension SignRenderer {
    /// SF Pro Compressed Black for the Drop look, SF Pro Rounded Heavy otherwise.
    static func font(_ size: CGFloat, look: ArrowLook) -> NSFont {
        guard look == .drop else { return font(size) }
        return NSFont.systemFont(ofSize: size, weight: .black, width: .compressed)
    }

    /// Fill in the sign colour, the ink edge fully inside it, no separate thin edge.
    static func drawDropBody(in context: CGContext, pill: CGSize, appearance: SignAppearance) {
        let shape = Pill(rect: CGRect(origin: .zero, size: pill), corners: appearance.corners)
        stroke(shape, in: context, line: (DropInk.edge, appearance.borderTint), fill: appearance.color)
    }
}
