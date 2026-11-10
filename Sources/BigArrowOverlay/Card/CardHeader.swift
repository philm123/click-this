import AppKit
import BigArrowCore

/// The card colour band: the title set like the arrow's sign (rounded heavy, centred, the
/// contrast colour), with the X in the top right corner and as much room on the left, so the
/// title stays centred.
@MainActor
final class CardHeader: NSView {
    static let vertical: CGFloat = 20
    static let corner: CGFloat = 12

    init(title: String, style: CardStyle, close: @escaping () -> Void) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = style.tint.cgColor
        let side = Self.corner + CardStyle.iconButton + 10
        let lead = style.isDrop ? CardStyle.padding : side
        let label = CardStyle.label("", font: style.titleFont, width: CardStyle.width - lead - side)
        label.attributedStringValue = Self.title(title, style: style)
        let button = ActionButton(icon: .close, tint: style.tint, tooltip: "Close") { close() }
        button.wantsLayer = true
        button.layer?.cornerRadius = style.isDrop ? 0 : CardStyle.iconButton / 2
        button.layer?.backgroundColor = (style.isDrop ? style.edge : style.onTint).cgColor
        if style.isDrop { Self.underline(self, style: style) }
        [label, button].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: lead),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Self.vertical),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.vertical),
            button.topAnchor.constraint(equalTo: topAnchor, constant: Self.corner),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.corner)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { preconditionFailure("cards are built in code") }

    /// Centred, as on the sign; flush left in the Drop look.
    static func title(_ text: String, style: CardStyle) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = style.isDrop ? .left : .center
        paragraph.lineBreakStrategy = .standard
        return NSAttributedString(string: text, attributes: [
            .font: style.titleFont, .foregroundColor: style.onTint, .paragraphStyle: paragraph
        ])
    }

    /// The Drop look's ink rule between header and rows.
    static func underline(_ header: NSView, style: CardStyle) {
        let rule = NSView()
        rule.wantsLayer = true
        rule.layer?.backgroundColor = style.edge.cgColor
        rule.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(rule)
        NSLayoutConstraint.activate([
            rule.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            rule.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            rule.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            rule.heightAnchor.constraint(equalToConstant: style.border)
        ])
    }
}

/// "Sent" after the last answer of a `keep` card: the contrast text centred on a rounded band
/// of the card colour, with Feather's check.
@MainActor
final class SentBanner: NSView {
    init(text: String, style: CardStyle) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = style.tint.cgColor
        layer?.cornerRadius = 12
        let icon = NSImageView(image: CardStyle.icon(.check))
        icon.contentTintColor = style.onTint
        let label = CardStyle.label(style.cased(text), font: style.buttonFont, color: style.onTint, width: CardStyle.contentWidth - 80)
        let line = Stack.horizontal([icon, label], spacing: 8)
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        NSLayoutConstraint.activate([
            line.centerXAnchor.constraint(equalTo: centerXAnchor),
            line.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            line.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { preconditionFailure("cards are built in code") }
}
