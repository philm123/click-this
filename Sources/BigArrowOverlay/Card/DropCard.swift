import AppKit
import BigArrowCore

/// The Drop look's hard shadows on cards: an ink slab behind the card, offset right and down,
/// and the same on buttons. No blur anywhere, and the window's own soft shadow is off.
@MainActor
enum DropCard {
    /// Gives a view a hard, unblurred shadow in the edge colour.
    static func hardShadow(_ view: NSView, style: CardStyle, offset: CGFloat) {
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        view.layer?.shadowColor = style.edge.cgColor
        view.layer?.shadowOpacity = 1
        view.layer?.shadowRadius = 0
        view.layer?.shadowOffset = CGSize(width: offset, height: -offset)
    }

    /// The card's window content: the card itself, or in the Drop look a holder with the ink
    /// slab and the card at its top left, so the card's own top-left points stay the window's.
    static func wrap(_ card: CardView) -> NSView {
        guard card.style.shadowInset > 0 else { return card }
        let holder = NSView(frame: .zero)
        let slab = NSView(frame: .zero)
        slab.wantsLayer = true
        slab.layer?.backgroundColor = card.style.edge.cgColor
        holder.addSubview(slab)
        holder.addSubview(card)
        layout(card)
        return holder
    }

    /// Puts card and slab in place after the card changed size.
    static func layout(_ card: CardView) {
        let inset = card.style.shadowInset
        guard inset > 0, let holder = card.superview, let slab = holder.subviews.first, slab !== card else { return }
        let size = card.fittingSize
        holder.setFrameSize(CGSize(width: size.width + inset, height: size.height + inset))
        card.frame = CGRect(x: 0, y: inset, width: size.width, height: size.height)
        slab.frame = CGRect(x: inset, y: 0, width: size.width, height: size.height)
    }

    /// The card's bitmap with its slab, for `card --png`.
    static func drawShadow(in context: CGContext, size: CGSize, style: CardStyle) {
        let inset = style.shadowInset
        context.setFillColor(style.edge.cgColor)
        context.fill(CGRect(x: inset, y: 0, width: size.width, height: size.height))
    }
}
