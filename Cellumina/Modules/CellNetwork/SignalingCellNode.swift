//
//  SignalingCellNode.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 11/02/26.
//


import SpriteKit
import UIKit

final class SignalingCellNode: SKNode {

    enum Style {
        case sender
        case receiver
        case autocrine
    }

    private(set) var style: Style
    private let radius: CGFloat

    // Layers
    private let membraneOuter = SKShapeNode()
    private let membraneInner = SKShapeNode()
    private let highlight = SKShapeNode()

    private let nucleus = SKShapeNode()

    private var receptors: [ReceptorNode] = []

    private var wobbleTimer: TimeInterval = 0
    private var basePoints: [CGPoint] = []
    private let pointCount = 22

    init(style: Style, radius: CGFloat) {
        self.style = style
        self.radius = radius
        super.init()
        isUserInteractionEnabled = false
        build()
        startMembraneWobble()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func colors() -> (fill: UIColor, stroke: UIColor, glow: UIColor) {
        switch style {
        case .sender:
            return (UIColor.systemTeal.withAlphaComponent(0.18),
                    UIColor.systemTeal.withAlphaComponent(0.55),
                    UIColor.systemTeal.withAlphaComponent(0.70))
        case .receiver:
            return (UIColor.systemIndigo.withAlphaComponent(0.16),
                    UIColor.systemIndigo.withAlphaComponent(0.55),
                    UIColor.systemIndigo.withAlphaComponent(0.70))
        case .autocrine:
            return (UIColor.systemGreen.withAlphaComponent(0.16),
                    UIColor.systemGreen.withAlphaComponent(0.55),
                    UIColor.systemGreen.withAlphaComponent(0.70))
        }
    }

    private func build() {
        // Base polygon points
        basePoints = makeBlobPoints(radius: radius, points: pointCount, wobble: 0.16)

        let outerPath = pathFrom(points: basePoints)
        let innerPath = pathFrom(points: basePoints.map { $0 * 0.92 })

        let c = colors()

        // Outer membrane 
        membraneOuter.path = outerPath
        membraneOuter.fillColor = c.fill
        membraneOuter.strokeColor = c.stroke
        membraneOuter.lineWidth = 4
        membraneOuter.glowWidth = 0
        addChild(membraneOuter)

        // Inner membrane
        membraneInner.path = innerPath
        membraneInner.fillColor = c.fill.withAlphaComponent(0.10)
        membraneInner.strokeColor = c.stroke.withAlphaComponent(0.30)
        membraneInner.lineWidth = 2
        membraneInner.glowWidth = 0
        addChild(membraneInner)

        // Highlight
        let hi = UIBezierPath(ovalIn: CGRect(x: -radius*0.55, y: radius*0.10,
                                            width: radius*0.65, height: radius*0.35))
        highlight.path = hi.cgPath
        highlight.fillColor = UIColor.white.withAlphaComponent(0.22)
        highlight.strokeColor = .clear
        highlight.zPosition = 2
        addChild(highlight)

        // Nucleus
        nucleus.path = pathFrom(points: makeBlobPoints(radius: radius * 0.38, points: 14, wobble: 0.10))
        nucleus.fillColor = UIColor.secondarySystemFill
        nucleus.strokeColor = UIColor.tertiaryLabel.withAlphaComponent(0.35)
        nucleus.lineWidth = 2
        nucleus.position = CGPoint(x: radius * 0.12, y: -radius * 0.08)
        nucleus.zPosition = 3
        addChild(nucleus)

        // Organelles
        let organelles = SKNode()
        organelles.zPosition = 1

        for _ in 0..<16 {
            let r = CGFloat.random(in: 2.5...6.0)
            let d = SKShapeNode(circleOfRadius: r)
            d.fillColor = UIColor.tertiarySystemFill
            d.strokeColor = .clear
            d.alpha = CGFloat.random(in: 0.50...0.85)

            let px = CGFloat.random(in: -radius*0.45...radius*0.45)
            let py = CGFloat.random(in: -radius*0.45...radius*0.45)
            d.position = CGPoint(x: px, y: py)

            organelles.addChild(d)
        }
        addChild(organelles)
    }

    func installReceptors(count: Int, receptorCategory: UInt32, skipping indicesToSkip: Set<Int> = []) {
        receptors.forEach { $0.removeFromParent() }
        receptors.removeAll()

        for i in 0..<count {
            if indicesToSkip.contains(i) { continue }

            let angle = (CGFloat(i) / CGFloat(count)) * (CGFloat.pi * 2)
            let p = CGPoint(
                x: cos(angle) * radius * 0.92,
                y: sin(angle) * radius * 0.92
            )

            let r = ReceptorNode(owner: self, radius: 7)
            r.position = p
            r.configurePhysics(receptorCategory: receptorCategory)
            receptors.append(r)
            addChild(r)
        }
    }

    func pulse() {
        let up = SKAction.scale(to: 1.04, duration: 0.12)
        up.timingMode = .easeOut
        let glowOn = SKAction.run { [weak self] in
            guard let self else {
                return
            }
            let c = self.colors()
            self.membraneOuter.glowWidth = 10
            self.membraneOuter.strokeColor = c.glow
        }

        let down = SKAction.scale(to: 1.0, duration: 0.16)
        down.timingMode = .easeInEaseOut

        let glowOff = SKAction.run { [weak self] in
            guard let self else {
                return
            }
            let c = self.colors()
            self.membraneOuter.glowWidth = 0
            self.membraneOuter.strokeColor = c.stroke
        }
        run(.sequence([glowOn, up, down, glowOff]))
    }

    func receiveSignal() {
        let glowOn = SKAction.run { [weak self] in
            guard let self else {
                return
            }
            self.nucleus.fillColor = UIColor.systemYellow.withAlphaComponent(0.55)
            self.nucleus.strokeColor = UIColor.systemYellow.withAlphaComponent(0.65)
            self.nucleus.glowWidth = 7
        }
        let wait = SKAction.wait(forDuration: 0.22)
        let glowOff = SKAction.run { [weak self] in
            guard let self else {
                return
            }
            self.nucleus.fillColor = UIColor.secondarySystemFill
            self.nucleus.strokeColor = UIColor.tertiaryLabel.withAlphaComponent(0.35)
            self.nucleus.glowWidth = 0
        }
        nucleus.run(.sequence([glowOn, wait, glowOff]))

        run(.sequence([.scale(to: 1.03, duration: 0.10), .scale(to: 1.0, duration: 0.14)]))
    }

    // MARK: - Amoeba wobble
    private func startMembraneWobble() {
        let tick = SKAction.customAction(withDuration: 99999) { [weak self] _, _ in
            guard let self else {
                return
            }
            self.wobbleTimer += 1.0 / 60.0
            self.updateWobble()
        }
        run(tick, withKey: "wobble")
    }

    private func updateWobble() {
        var pts: [CGPoint] = []
        pts.reserveCapacity(pointCount)

        for i in 0..<pointCount {
            let t = wobbleTimer
            let phase = CGFloat(i) * 0.35
            let wob = (sin(CGFloat(t) * 2.1 + phase) + sin(CGFloat(t) * 3.4 - phase)) * 0.5
            let scale = 1.0 + wob * 0.02

            let p = basePoints[i] * scale
            pts.append(p)
        }

        let outer = pathFrom(points: pts)
        let inner = pathFrom(points: pts.map { $0 * 0.92 })

        membraneOuter.path = outer
        membraneInner.path = inner
    }
}

// MARK: - Geometry helpers
private func makeBlobPoints(radius: CGFloat, points: Int, wobble: CGFloat) -> [CGPoint] {
    let n = max(12, points)
    var pts: [CGPoint] = []
    pts.reserveCapacity(n)

    for i in 0..<n {
        let t = CGFloat(i) / CGFloat(n)
        let ang = t * (CGFloat.pi * 2)

        let w1 = sin(ang * 2.0 + 0.9)
        let w2 = sin(ang * 5.0 - 1.7)
        let wob = 1.0 + (w1 * 0.06 + w2 * 0.04) * wobble

        let r = radius * wob
        pts.append(CGPoint(x: cos(ang) * r, y: sin(ang) * r))
    }
    return pts
}

private func pathFrom(points: [CGPoint]) -> CGPath {
    let p = UIBezierPath()
    guard let first = points.first else {
        return p.cgPath
    }
    p.move(to: first)
    for pt in points.dropFirst() { p.addLine(to: pt) }
    p.close()
    return p.cgPath
}

private extension CGPoint {
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}
