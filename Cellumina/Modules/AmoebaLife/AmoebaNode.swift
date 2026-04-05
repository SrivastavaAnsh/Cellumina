//
//  AmoebaNode.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import SpriteKit
import UIKit

final class AmoebaNode: SKNode {

    let baseRadius: CGFloat = 86
    private var reduceMotion: Bool = false

    private let membrane = SKShapeNode()
    private let innerGlow = SKShapeNode()

    private var stretchDir = CGVector(dx: 0, dy: 0)
    private var wobbleT: CGFloat = 0
    private var gulpT: CGFloat = 0

    override init() {
        super.init()

        innerGlow.fillColor = UIColor.label.withAlphaComponent(0.10)
        innerGlow.strokeColor = .clear
        innerGlow.zPosition = 0
        addChild(innerGlow)

        membrane.fillColor = UIColor.label.withAlphaComponent(0.08)
        membrane.strokeColor = UIColor.label.withAlphaComponent(0.28)
        membrane.lineWidth = 2.5
        membrane.zPosition = 1
        addChild(membrane)

        refreshPath()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setReduceMotion(_ v: Bool) {
        reduceMotion = v
    }

    func setStretchDirection(_ dir: CGVector) {
        stretchDir = dir
    }

    func gulpPulse() {
        gulpT = 1.0
    }
    
    func applyTheme(traits: UITraitCollection) {
        innerGlow.fillColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.10)
        membrane.fillColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.08)
        membrane.strokeColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.28)
    }

    func tick(dt: TimeInterval) {
        let speed: CGFloat = reduceMotion ? 0.6 : 1.0
        wobbleT += CGFloat(dt) * 2.2 * speed

        if gulpT > 0 {
            gulpT = max(0, gulpT - CGFloat(dt) * 2.8)
        }

        refreshPath()
    }

    private func refreshPath() {
        let stretch = reduceMotion ? 0.10 : 0.16
        let gulp = (gulpT > 0) ? (0.10 * gulpT) : 0

        let path = AmoebaPhysics.organicBlobPath(
            center: .zero,
            baseRadius: baseRadius,
            points: 18,
            wobble: reduceMotion ? 0.08 : 0.12,
            time: wobbleT,
            stretchDir: stretchDir,
            stretchAmount: stretch + gulp
        )

        membrane.path = path
        innerGlow.path = AmoebaPhysics.insetPath(path, inset: 10)
    }
}
