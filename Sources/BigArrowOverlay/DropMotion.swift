import AppKit
import BigArrowCore

/// How the Drop look lands: the sign slams down from above the screen with a twist, the shaft
/// fires out fast, the head stamps on the target, the screen kicks once and the ink splat bursts.
extension Animator {
    /// From the start until the head lands, the moment `--sound` hits.
    static let dropLanding: CFTimeInterval = 0.26
    static let slamScale: CGFloat = 1.5

    static func drop(_ layers: OverlayLayers) {
        let now = CACurrentMediaTime()
        let landing = now + dropLanding
        for shaft in layers.shaftLayers {
            let draw = CABasicAnimation(keyPath: "strokeEnd")
            draw.fromValue = 0
            draw.toValue = 1
            draw.duration = dropLanding * 0.85
            draw.timingFunction = CAMediaTimingFunction(name: .easeIn)
            shaft.add(draw, forKey: "drawOn")
        }
        for head in layers.headLayers {
            slam(head, from: 0.1, begin: landing)
            pulse(head, begin: landing + 0.9)
        }
        for layer in [layers.signEdge, layers.sign, layers.signText] {
            slam(layer, from: slamScale, begin: now)
            twist(layer, begin: now)
            fade(layer, from: 0, to: 1, duration: 0.08)
        }
        fade(layers.markGroup, from: 0, to: 1, duration: 0.12)
        pulse(layers.markGroup, begin: landing + 0.9)
        kick(layers.root, begin: landing)
        burst(layers.splat, begin: landing)
    }

    /// A stiff spring: fast in, one small overshoot.
    static func slam(_ layer: CALayer, from scale: CGFloat, begin: CFTimeInterval) {
        let spring = CASpringAnimation(keyPath: "transform.scale")
        spring.fromValue = scale
        spring.toValue = 1
        spring.damping = 16
        spring.stiffness = 700
        spring.duration = spring.settlingDuration
        spring.beginTime = begin
        spring.fillMode = .backwards
        layer.add(spring, forKey: "slam")
    }

    static func twist(_ layer: CALayer, begin: CFTimeInterval) {
        let twist = CABasicAnimation(keyPath: "transform.rotation.z")
        twist.fromValue = -0.08
        twist.toValue = 0
        twist.duration = 0.22
        twist.beginTime = begin
        twist.fillMode = .backwards
        twist.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(twist, forKey: "twist")
    }

    /// The whole overlay jolts a few points on impact.
    static func kick(_ layer: CALayer, begin: CFTimeInterval) {
        let kick = CAKeyframeAnimation(keyPath: "transform.translation.y")
        kick.values = [0, -7, 5, -2, 0]
        kick.duration = 0.2
        kick.beginTime = begin
        kick.isAdditive = true
        layer.add(kick, forKey: "kick")
    }

    /// The splat grows out of the tip and fades; its resting opacity is 0.
    static func burst(_ layer: CALayer, begin: CFTimeInterval) {
        let grow = CABasicAnimation(keyPath: "transform.scale")
        grow.fromValue = 0.3
        grow.toValue = 1.25
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [grow, fadeOut]
        group.duration = 0.55
        group.beginTime = begin
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(group, forKey: "burst")
    }
}
