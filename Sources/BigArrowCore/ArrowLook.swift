import CoreGraphics
import Foundation

/// `--look`: the whole style of arrow, sign and card at once.
public enum ArrowLook: String, CaseIterable, Sendable, Codable {
    /// Rounded heavy type, pill signs, white border and a soft shadow.
    case classic
    /// Heavy streetwear: compressed black caps, square signs, a thick ink edge and a hard,
    /// unblurred shadow. Default colour acid; the colorways are acid, flare, cobalt, ink, cement, gum.
    case drop

    public static func parse(_ raw: String) throws -> ArrowLook {
        guard let look = ArrowLook(rawValue: raw.lowercased()) else {
            throw BigArrowError.badInput("look '\(raw)' is not one of \(allCases.map(\.rawValue).joined(separator: ", "))")
        }
        return look
    }

    /// The colour when neither `--color` nor the card names one.
    public var defaultColor: String {
        switch self {
        case .classic: "red"
        case .drop: "acid"
        }
    }

    /// The sign's default corners.
    public var defaultCorners: String {
        switch self {
        case .classic: "round"
        case .drop: "sharp"
        }
    }

    /// The sign's font size against the classic size: compressed letters need more height to weigh as much.
    public var fontScale: CGFloat {
        switch self {
        case .classic: 1
        case .drop: 1.22
        }
    }
}

/// The fixed parts of the Drop look.
public enum DropInk {
    /// Near-black ink: edges, shadows, rules.
    public static let ink = ArrowColor(red: 0x0B / 255, green: 0x0B / 255, blue: 0x0B / 255)
    /// The acid of the ink colorway's edge and shadow, where ink would vanish.
    public static let acid = ArrowColor(red: 0xD4 / 255, green: 1, blue: 0)
    /// Off-white card paper.
    public static let paper = ArrowColor(red: 0xF4 / 255, green: 0xF2 / 255, blue: 0xEC / 255)
    /// The sign's edge, per side, and the arrow's outline added to a stroke (both sides).
    public static let edge: CGFloat = 5
    public static let outline: CGFloat = 10
    /// The hard shadow's offset down and to the right, in points.
    public static let shadow: CGFloat = 8

    /// Ink, or acid on colours too dark for ink to show.
    public static func edge(for color: ArrowColor) -> ArrowColor {
        color.luminance < 0.12 ? acid : ink
    }
}
