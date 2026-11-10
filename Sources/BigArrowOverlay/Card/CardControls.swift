import AppKit
import BigArrowCore

/// What the human does on a card, handed to whoever runs it.
@MainActor
public final class CardEvents {
    /// A copy button: the row and the value to put on the clipboard (a TOTP row's current code).
    public var copy: (CardRow, String) -> Void = { _, _ in }
    /// A link opened.
    public var open: (String) -> Void = { _ in }
    /// A row is answered: the row, the outcome and its value (button id, option id, typed text).
    public var answer: (CardRow, CardOutcome, String?) -> Void = { _, _, _ in }
    /// The X button or Esc.
    public var close: () -> Void = {}
    /// A row (or checklist item) with a `point` became the one the human is working on.
    public var activate: (CardPoint, String) -> Void = { _, _ in }
    /// Checklist ticks and typed text, as they change.
    public var checked: ([String]) -> Void = { _ in }
    public var typed: (String, String) -> Void = { _, _ in }

    public init() {}
}

/// A borderless button that runs a closure and takes the first click, so it works while the
/// card's panel is not key and the human's app stays active.
@MainActor
final class ActionButton: NSButton {
    var handler: () -> Void = {}

    convenience init(icon: FeatherIcon, tint: NSColor, tooltip: String, handler: @escaping () -> Void) {
        self.init(frame: .zero)
        image = CardStyle.icon(icon)
        imagePosition = .imageOnly
        isBordered = false
        contentTintColor = tint
        toolTip = tooltip
        setAccessibilityLabel(tooltip)
        self.handler = handler
        target = self
        action = #selector(run)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: CardStyle.iconButton),
            heightAnchor.constraint(equalToConstant: CardStyle.iconButton)
        ])
    }

    /// Swaps the icon for a moment, e.g. copy to check.
    func flash(_ icon: FeatherIcon, back original: FeatherIcon) {
        image = CardStyle.icon(icon)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            MainActor.assumeIsolated { self?.image = CardStyle.icon(original) }
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        CardMotion.press(self)
        super.mouseDown(with: event)
    }

    @objc func run() {
        handler()
    }
}

/// A text button: `primary` filled in the card colour, otherwise outlined.
@MainActor
final class PillButton: NSButton {
    var handler: () -> Void = {}

    convenience init(_ title: String, primary: Bool, style: CardStyle, handler: @escaping () -> Void) {
        self.init(frame: .zero)
        isBordered = false
        wantsLayer = true
        layer?.cornerRadius = style.isDrop ? 0 : 10
        layer?.borderWidth = style.isDrop ? 3 : (primary ? 0 : 2)
        layer?.borderColor = (style.isDrop ? style.edge : style.tint).cgColor
        layer?.backgroundColor = primary ? style.tint.cgColor : NSColor.clear.cgColor
        let ink = style.isDrop && !primary ? style.edge : (primary ? style.onTint : style.tint)
        attributedTitle = NSAttributedString(string: style.cased(title), attributes: [.font: style.buttonFont, .foregroundColor: ink])
        if style.isDrop { DropCard.hardShadow(self, style: style, offset: 4) }
        setAccessibilityLabel(title)
        self.handler = handler
        self.primary = primary
        self.tint = style.tint
        self.font = style.buttonFont
        chosenText = style.isDrop ? style.onTint : .white
        target = self
        action = #selector(run)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 42).isActive = true
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self))
    }

    private var primary = false
    private var tint = NSColor.systemRed
    /// The picked answer's text: white, the contrast colour in the Drop look.
    private var chosenText = NSColor.white
    /// False once its question is answered. The button stays enabled: a disabled button draws its
    /// title in the system's disabled colour, which would hide the picked answer.
    var isAnswerable = true

    /// Under the pointer a filled button gets lighter and an outlined one fills faintly.
    override func mouseEntered(with event: NSEvent) {
        guard isAnswerable else { return }
        layer?.backgroundColor = primary ? tint.blended(withFraction: 0.18, of: .white)?.cgColor : tint.withAlphaComponent(0.12).cgColor
    }

    override func mouseExited(with event: NSEvent) {
        guard isAnswerable else { return }
        layer?.backgroundColor = primary ? tint.cgColor : NSColor.clear.cgColor
    }

    override func mouseDown(with event: NSEvent) {
        guard isAnswerable else { return }
        CardMotion.press(self)
        super.mouseDown(with: event)
    }

    /// The answer that was given: filled, whatever it looked like before.
    func markChosen() {
        layer?.backgroundColor = tint.cgColor
        let attributes: [NSAttributedString.Key: Any] = [.font: font ?? CardStyle.buttonFont, .foregroundColor: chosenText]
        attributedTitle = NSAttributedString(string: attributedTitle.string, attributes: attributes)
    }

    override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        return NSSize(width: size.width + 32, height: max(size.height + 16, 42))
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    @objc func run() {
        guard isAnswerable else { return }
        handler()
    }
}

/// Stacks views vertically or horizontally with the card's spacing.
@MainActor
enum Stack {
    static func vertical(_ views: [NSView], spacing: CGFloat = 6) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = spacing
        return stack
    }

    static func horizontal(_ views: [NSView], spacing: CGFloat = 8) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = spacing
        return stack
    }
}
