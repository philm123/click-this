import AppKit
import BigArrowCore

/// The Drop look's layer details: square caps and miter joins, one hard shadow without blur,
/// and the ink splat that bursts at the tip as the arrow lands.
extension OverlayLayers {
    /// The splat: a dashed ring and four ink-edged drops around the tip.
    static let splatRadius: CGFloat = 40

    /// The shadow of the whole arrow: soft by default, hard and offset in the Drop look.
    func finish(_ appearance: SignAppearance, tip: CGPoint) {
        guard look == .drop else {
            if appearance.border.hasShadow { Self.shadow(root) }
            return
        }
        root.shadowColor = appearance.borderTint.cgColor
        root.shadowOpacity = 1
        root.shadowRadius = 0
        root.shadowOffset = CGSize(width: DropInk.shadow, height: -DropInk.shadow)
        let shapes: [CALayer] = shaftLayers + headLayers + (markGroup.sublayers ?? [])
        for case let layer as CAShapeLayer in shapes {
            layer.lineCap = .square
            layer.lineJoin = .miter
            layer.miterLimit = 4
        }
        Self.buildSplat(splat, at: tip, color: appearance.color, edge: appearance.borderTint)
    }

    /// Hidden until `Animator` bursts it, so a PNG shows the arrow at rest.
    static func buildSplat(_ group: CALayer, at tip: CGPoint, color: ArrowColor, edge: ArrowColor) {
        let size = splatRadius * 3
        group.frame = CGRect(x: tip.x - size / 2, y: tip.y - size / 2, width: size, height: size)
        group.opacity = 0
        let center = CGPoint(x: size / 2, y: size / 2)
        let ring = CAShapeLayer()
        ring.path = CGPath(ellipseIn: CGRect(x: center.x - splatRadius, y: center.y - splatRadius,
                                             width: splatRadius * 2, height: splatRadius * 2), transform: nil)
        ring.fillColor = nil
        ring.strokeColor = color.cgColor
        ring.lineWidth = 6
        ring.lineDashPattern = [8, 11]
        let drops: [(CGFloat, CGFloat, CGFloat)] = [(-50, 24, 8), (48, 36, 6), (56, -24, 10), (-32, -44, 5)]
        group.sublayers = [ring] + drops.map { dx, dy, radius in
            let drop = CAShapeLayer()
            drop.path = CGPath(ellipseIn: CGRect(x: center.x + dx - radius, y: center.y + dy - radius,
                                                 width: radius * 2, height: radius * 2), transform: nil)
            drop.fillColor = color.cgColor
            drop.strokeColor = edge.cgColor
            drop.lineWidth = 3
            return drop
        }
    }
}
