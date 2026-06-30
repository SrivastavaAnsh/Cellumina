//
//  CellNetworkScene.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 10/02/26.
//

import SpriteKit
import UIKit

final class CellNetworkScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Nodes
    private var cells: [SignalingCellNode] = []
    private var vesselNode: SKShapeNode?

    private var labelNodes: [SKNode] = []
    private var mode: SignalType = .paracrine

    private let signalCategory: UInt32 = 1 << 0
    private let receptorCategory: UInt32 = 1 << 1

    private var didConfigure = false
    private var didBuildOnceWithValidSize = false

    
    // MARK: - Appearance handling
    private var uiStyle: UIUserInterfaceStyle = .unspecified

    func setInterfaceStyle(_ style: UIUserInterfaceStyle) {
        guard uiStyle != style else {
            return
        }
        uiStyle = style

        if size.width > 10, size.height > 10, didBuildOnceWithValidSize {
            let bgColor = UIColor.systemBackground.resolvedColor(with: trait)
            for container in labelNodes {
                if let bg = container.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    bg.fillColor = bgColor.withAlphaComponent(0.70)
                }
            }
        }
    }

    private var trait: UITraitCollection {
        UITraitCollection(userInterfaceStyle: uiStyle)
    }

    func configure() {
        guard !didConfigure else {
            return
        }
        didConfigure = true

        scaleMode = .resizeFill

        backgroundColor = .clear

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    func setMode(_ newMode: SignalType) {
        mode = newMode
        if size.width > 10, size.height > 10 {
            reset()
        }
    }

    func reset() {
        guard size.width > 10, size.height > 10 else {
            return
        }

        removeAllChildren()
        clearLabels()
        cells.removeAll()
        vesselNode = nil

        addBackground()

        switch mode {
        case .paracrine:
            buildParacrine()
        case .autocrine:
            buildAutocrine()
        case .endocrine:
            buildEndocrine()
        }

        didBuildOnceWithValidSize = true
    }

    func modeHelpText(for mode: SignalType) -> String {
        switch mode {
        case .paracrine:
            return "Tap the Signaling cell → it releases signals → nearby cell receptors bind and activate."
        case .autocrine:
            return "Tap the cell → it signals itself → receptor binds → nucleus lights up."
        case .endocrine:
            return "Tap the gland cell → hormone enters the vessel → travels to a distant target cell."
        }
    }

    // MARK: - Lifecycle Hooks
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        configure()
        view.allowsTransparency = true

        if size.width > 10, size.height > 10, !didBuildOnceWithValidSize {
            reset()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        if size.width > 10, size.height > 10 {
            if !didBuildOnceWithValidSize || oldSize == .zero {
                reset()
            }
        }
    }

    // MARK: - Build Worlds
    private func addBackground() {
        let bg = SKNode()
        let count = 45

        let dotColor = UIColor.systemGray.withAlphaComponent(0.40)

        for _ in 0..<count {
            let d = CGFloat.random(in: 2...5)
            let dot = SKShapeNode(circleOfRadius: d)
            dot.fillColor = dotColor
            dot.strokeColor = .clear
            dot.alpha = CGFloat.random(in: 0.25...0.55)
            dot.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            dot.name = "bgDot"
            bg.addChild(dot)
        }
        addChild(bg)
    }

    private func buildParacrine() {
        let left = SignalingCellNode(style: .sender, radius: min(size.width, size.height) * 0.18)
        let right = SignalingCellNode(style: .receiver, radius: min(size.width, size.height) * 0.18)

        left.position = CGPoint(x: size.width * 0.32, y: size.height * 0.52)
        right.position = CGPoint(x: size.width * 0.70, y: size.height * 0.52)

        right.installReceptors(count: 8, receptorCategory: receptorCategory)

        addChild(left)
        addChild(right)
        cells = [left, right]

        let leftPill = makePillLabel("Signaling cell", tint: .systemTeal)
        let rightPill = makePillLabel("Nearby cell", tint: .systemIndigo)

        placePill(leftPill, near: left, dy: min(size.width, size.height) * 0.05)
        placePill(rightPill, near: right, dy: min(size.width, size.height) * 0.05)
    }

    private func buildAutocrine() {
        let cell = SignalingCellNode(style: .autocrine, radius: min(size.width, size.height) * 0.20)
        cell.position = CGPoint(x: size.width * 0.50, y: size.height * 0.55)

        cell.installReceptors(count: 10, receptorCategory: receptorCategory)

        addChild(cell)
        cells = [cell]

        let pill = makePillLabel("Same cell (self-signaling)", tint: .systemGreen)
        placePill(pill, near: cell, dy: min(size.width, size.height) * 0.05)
    }

    private func buildEndocrine() {
        let vesselHeight: CGFloat = 78
        let y = size.height * 0.49

        let rect = CGRect(
            x: size.width * 0.08,
            y: y - vesselHeight/2,
            width: size.width * 0.84,
            height: vesselHeight
        )

        let vessel = SKShapeNode(rect: rect, cornerRadius: vesselHeight/2)
        vessel.fillColor = UIColor.systemRed.withAlphaComponent(0.12)
        vessel.strokeColor = UIColor.systemRed.withAlphaComponent(0.25)
        vessel.lineWidth = 2
        addChild(vessel)
        vesselNode = vessel

        let gland = SignalingCellNode(style: .sender, radius: min(size.width, size.height) * 0.16)
        let target = SignalingCellNode(style: .receiver, radius: min(size.width, size.height) * 0.18)

        gland.position = CGPoint(x: size.width * 0.23, y: size.height * 0.72)
        target.position = CGPoint(x: size.width * 0.78, y: size.height * 0.25)

        target.installReceptors(
            count: 9,
            receptorCategory: receptorCategory,
            skipping: [1, 2]
        )

        addChild(gland)
        addChild(target)
        cells = [gland, target]

        let glandPill = makePillLabel("Endocrine gland", tint: .systemTeal)
        let targetPill = makePillLabel("Target cell", tint: .systemIndigo)

        placePill(glandPill, near: gland, dy: min(size.width, size.height) * 0.035)
        placePill(targetPill, near: target, dy: min(size.width, size.height) * 0.035)

        let bloodLabel = SKLabelNode(fontNamed: "SF Pro Rounded")
        bloodLabel.text = "Blood vessel"
        bloodLabel.fontColor = UIColor.systemRed.withAlphaComponent(0.65)
        bloodLabel.horizontalAlignmentMode = .center
        bloodLabel.verticalAlignmentMode = .center
        bloodLabel.zPosition = 220

        let base = min(size.width, size.height)
        bloodLabel.fontSize = max(12, min(17, base * 0.026))

        bloodLabel.position = CGPoint(x: rect.midX, y: rect.midY)
        addChild(bloodLabel)

        labelNodes.append(bloodLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        let p = t.location(in: self)

        let hit = nodes(at: p)
        let tappedCell =
            hit.compactMap { $0 as? SignalingCellNode }.first ??
            hit.compactMap { $0.parent as? SignalingCellNode }.first

        guard let cell = tappedCell else {
            return
        }
        DispatchQueue.main.async { Haptics.tap() }
        emitSignals(from: cell)
    }

    func demoSignal() {
        guard let sender = cells.first else {
            return
        }
        emitSignals(from: sender)
    }

    private func emitSignals(from sender: SignalingCellNode) {
        switch mode {
        case .paracrine:
            guard cells.count == 2 else {
                return
            }
            guard sender === cells[0] else {
                return
            }
            let receiver = cells[1]
            spawnSignalBurst(sender: sender, target: receiver, count: 18)

        case .autocrine:
            guard let only = cells.first else {
                return
            }
            spawnSignalBurst(sender: only, target: only, count: 18)

        case .endocrine:
            guard cells.count == 2 else {
                return
            }
            guard sender === cells[0] else {
                return
            }
            let target = cells[1]
            spawnEndocrine(sender: sender, target: target, count: 14)
        }
    }

    // MARK: - Signal Spawning
    private func spawnSignalBurst(sender: SignalingCellNode, target: SignalingCellNode, count: Int) {
        sender.pulse()

        let origin = sender.position
        let targetPoint = target.position

        for i in 0..<count {
            let s = SignalParticleNode(radius: CGFloat.random(in: 4.0...6.0))
            s.position = origin.jittered(dx: 12, dy: 12)

            s.configurePhysics(signalCategory: signalCategory,
                               receptorCategory: receptorCategory)

            addChild(s)

            let delay = Double(i) * 0.015
            run(.sequence([
                .wait(forDuration: delay),
                .run {
                    let v = CGVector(from: s.position, to: targetPoint,
                                     magnitude: CGFloat.random(in: 120...210))
                    s.physicsBody?.velocity = v
                    s.wobble()
                }
            ]))
        }
    }

    private func spawnEndocrine(sender: SignalingCellNode, target: SignalingCellNode, count: Int) {
        sender.pulse()
        guard let vessel = vesselNode else {
            return
        }

        let vesselRect = vessel.path?.boundingBox ?? CGRect(x: 0, y: 0, width: size.width, height: 80)
        let entry = CGPoint(x: vesselRect.minX + 30, y: vesselRect.midY)
        let exit = CGPoint(x: vesselRect.maxX - 30, y: vesselRect.midY)

        for i in 0..<count {
            let s = SignalParticleNode(radius: CGFloat.random(in: 4.0...6.0))
            s.position = sender.position.jittered(dx: 10, dy: 10)
            s.configurePhysics(signalCategory: signalCategory,
                               receptorCategory: receptorCategory)
            addChild(s)

            let delay = Double(i) * 0.02

            let goToEntry = SKAction.move(to: entry.jittered(dx: 8, dy: 10), duration: 0.35)
            goToEntry.timingMode = .easeInEaseOut

            let travel = SKAction.move(to: exit.jittered(dx: 8, dy: 10), duration: 0.60)
            travel.timingMode = .easeInEaseOut

            let toTarget = SKAction.move(to: target.position.jittered(dx: 18, dy: 18), duration: 0.45)
            toTarget.timingMode = .easeInEaseOut

            s.run(.sequence([
                .wait(forDuration: delay),
                goToEntry,
                travel,
                toTarget
            ])) {
                let randomAngle = CGFloat.random(in: 0...(CGFloat.pi * 2))
                let randomRadius = target.frame.width * 0.5

                let randomTargetPoint = CGPoint(
                    x: target.position.x + cos(randomAngle) * randomRadius,
                    y: target.position.y + sin(randomAngle) * randomRadius
                )

                let v = CGVector(from: s.position, to: randomTargetPoint, magnitude: 120)
                s.physicsBody?.velocity = v
                s.wobble()
            }
        }
    }

    // MARK: - relayout on oriention change
    func updateSize(_ newSize: CGSize) {
        guard newSize.width > 10, newSize.height > 10 else {
            return
        }
        if size != newSize {
            size = newSize
            reset()
        }
    }

    // MARK: - Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node
        let b = contact.bodyB.node

        let signal = (a as? SignalParticleNode) ?? (b as? SignalParticleNode)
        let receptor = (a as? ReceptorNode) ?? (b as? ReceptorNode)

        guard let signal, let receptor else {
            return
        }
        guard let cell = receptor.ownerCell else {
            return
        }

        signal.consume()
        receptor.activate()
        cell.receiveSignal()
    }

    private func clearLabels() {
        labelNodes.forEach { $0.removeFromParent() }
        labelNodes.removeAll()
    }

    private func makePillLabel(_ text: String, tint: UIColor) -> SKNode {
        let base = min(size.width, size.height)
        let fontSize = max(12, min(16, base * 0.026))

        let label = SKLabelNode(fontNamed: "SF Pro Rounded")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = tint
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 210

        label.position = CGPoint(x: 0, y: fontSize * 0.001)

        let textW = label.frame.width
        let textH = label.frame.height

        let padX = fontSize * 0.95
        let padY = fontSize * 0.60

        let w = textW + padX * 2
        let h = textH + padY * 2
        let bgColor = UIColor.systemBackground.resolvedColor(with: trait)

        let bg = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: h / 2)
        bg.fillColor = bgColor.withAlphaComponent(0.70)
        bg.strokeColor = tint.withAlphaComponent(0.25)
        bg.lineWidth = 1
        bg.zPosition = 205

        let container = SKNode()
        container.zPosition = 200
        container.addChild(bg)
        container.addChild(label)

        labelNodes.append(container)
        return container
    }

    private func placePill(_ pill: SKNode, near node: SKNode, dy: CGFloat) {
        let f = node.calculateAccumulatedFrame()
        pill.position = CGPoint(x: f.midX, y: f.minY - dy)
        addChild(pill)
    }
}

// MARK: - Helpers
private extension CGPoint {
    func jittered(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + CGFloat.random(in: -dx...dx),
                y: y + CGFloat.random(in: -dy...dy))
    }
}

private extension CGVector {
    init(from: CGPoint, to: CGPoint, magnitude: CGFloat) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = max(0.001, sqrt(dx*dx + dy*dy))
        let nx = dx / len
        let ny = dy / len
        self.init(dx: nx * magnitude, dy: ny * magnitude)
    }
}
