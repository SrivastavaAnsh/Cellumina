//
//  VacuoleNode.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import SpriteKit
import UIKit

final class VacuoleNode: SKNode {

    private var reduceMotion: Bool = false

    private let bubble = SKShapeNode()
    private let ring = SKShapeNode()

    private let baseR: CGFloat
    private var fill: CGFloat = 0.2
    private var pulseAcc: CGFloat = 0

    init(radius: CGFloat) {
        self.baseR = radius
        super.init()

        bubble.path = CGPath(ellipseIn: CGRect(x: -baseR, y: -baseR, width: baseR*2, height: baseR*2), transform: nil)
        bubble.fillColor = UIColor.label.withAlphaComponent(0.08)
        bubble.strokeColor = .clear
        addChild(bubble)

        ring.path = CGPath(ellipseIn: CGRect(x: -baseR, y: -baseR, width: baseR*2, height: baseR*2), transform: nil)
        ring.strokeColor = UIColor.label.withAlphaComponent(0.26)
        ring.lineWidth = 1
        ring.fillColor = .clear
        addChild(ring)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setReduceMotion(_ v: Bool) {
        reduceMotion = v
    }
    
    func applyTheme(traits: UITraitCollection) {
        bubble.fillColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.08 + 0.10 * fill)
        ring.strokeColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.26)
    }

    func bump() {
        let dur = reduceMotion ? 0.18 : 0.12
        run(.sequence([
            .scale(to: 1.12, duration: dur),
            .scale(to: 1.0, duration: dur)
        ]))
    }

    func tick(dt: TimeInterval, water: CGFloat, onDrain: (CGFloat) -> Void) {
        let fillRate: CGFloat = 0.002 + water * 0.006
        fill = min(1, fill + fillRate * CGFloat(dt * 60))

        if fill >= 0.98 {
            pulseAcc += CGFloat(dt)
            let pulseDur: CGFloat = reduceMotion ? 0.35 : 0.25

            let drainPerFrame: CGFloat = 0.018
            onDrain(drainPerFrame * CGFloat(dt * 60))

            let scaleUp: CGFloat = 1.22
            let t = min(1, pulseAcc / pulseDur)
            let s = 1.0 + (scaleUp - 1.0) * (1 - (1 - t) * (1 - t))
            setScale(s)

            if pulseAcc >= pulseDur {
                pulseAcc = 0
                fill = 0.18
                setScale(1.0)
            }
        } else {
            if !reduceMotion {
                let breath = 1.0 + 0.03 * sin(CGFloat(CACurrentMediaTime()) * 2.0)
                setScale(breath)
            } else {
                setScale(1.0)
            }
        }

        bubble.fillColor = UIColor.label.withAlphaComponent(0.08 + 0.10 * fill)
    }
}
