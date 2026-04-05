//
//  AmoebaScene.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import SpriteKit
import UIKit

final class AmoebaScene: SKScene, SKPhysicsContactDelegate {

    var onHUD: ((AmoebaHUDState) -> Void)?
    var onInfo: ((AmoebaInfoPayload) -> Void)?
    
    var onEnergyEmpty: (() -> Void)?

    private var didTriggerEnergyEmpty = false
    private var reduceMotion: Bool = false

    private let worldNode = SKNode()
    private let cameraNode = SKCameraNode()

    private var amoeba = AmoebaNode()
    private var vacuole = VacuoleNode(radius: 14)
    private var nucleus = SKShapeNode(circleOfRadius: 18)

    private var energy: CGFloat = 0.70 { didSet { publishHUD() } }
    private var water: CGFloat = 0.25 { didSet { publishHUD() } }

    private var lastUpdateTime: TimeInterval = 0
    private var bacteriaSpawnAcc: TimeInterval = 0
    private var didInitialLayout = false

    private var currentStyle: UIUserInterfaceStyle = .unspecified

    private let amoebaForce: CGFloat = 300      // range -> 250 to 400
    private let amoebaMaxSpeed: CGFloat = 520

    private let inset: CGFloat = 22

    // MARK: - configure
    func configure(reduceMotion: Bool) {
        self.reduceMotion = reduceMotion

        didTriggerEnergyEmpty = false
        isPaused = false
        
        worldNode.removeAllChildren()
        worldNode.removeAllActions()

        removeAllChildren()
        removeAllActions()

        scaleMode = .resizeFill

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        addChild(worldNode)
        camera = cameraNode
        addChild(cameraNode)

        setupParticles()
        setupAmoeba()

        applyTheme()

        publishHUD()
    }

    func setInterfaceStyle(_ style: UIUserInterfaceStyle) {
        currentStyle = style
        applyTheme()
    }

    private func applyTheme() {
        let styleToUse: UIUserInterfaceStyle = (currentStyle == .unspecified) ? .light : currentStyle
        let traits = UITraitCollection(userInterfaceStyle: styleToUse)

        backgroundColor = .clear

        if let dust = worldNode.childNode(withName: "dust") as? SKEmitterNode {
            dust.particleColor = UIColor.systemGray.withAlphaComponent(0.35)
        }

        amoeba.applyTheme(traits: traits)

        nucleus.fillColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.16)
        nucleus.strokeColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.28)

        vacuole.applyTheme(traits: traits)

        for n in worldNode.children {
            if let b = n as? BacteriaNode {
                b.applyTheme(traits: traits)
            }
        }
    }

    func setReduceMotion(_ v: Bool) {
        reduceMotion = v
        amoeba.setReduceMotion(v)
        vacuole.setReduceMotion(v)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutWorld()
    }

    func onResize(to newSize: CGSize) {
        layoutWorld()
    }

    func resetRun() {
        energy = 0.70
        water = 0.25
        lastUpdateTime = 0
        bacteriaSpawnAcc = 0
        didInitialLayout = false
        didTriggerEnergyEmpty = false
        isPaused = false

        worldNode.removeAllChildren()
        setupParticles()
        setupAmoeba()

        applyTheme()

        publishHUD()
    }

    private func layoutWorld() {
        cameraNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

        if let dust = worldNode.childNode(withName: "dust") as? SKEmitterNode {
            dust.position = CGPoint(x: size.width/2, y: size.height/2)
            dust.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        }

        if amoeba.parent != nil {
            amoeba.position = clampPoint(
                CGPoint(x: size.width * 0.5, y: size.height * 0.55),
                padding: amoeba.baseRadius + inset
            )
            amoeba.physicsBody?.velocity = .zero
        }

        didInitialLayout = true
    }

    private func setupAmoeba() {
        amoeba = AmoebaNode()
        amoeba.setReduceMotion(reduceMotion)
        worldNode.addChild(amoeba)

        let body = SKPhysicsBody(circleOfRadius: amoeba.baseRadius * 0.9)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.linearDamping = 3.2
        body.categoryBitMask = PhysicsCategory.amoeba
        body.contactTestBitMask = PhysicsCategory.bacteria
        body.collisionBitMask = 0
        amoeba.physicsBody = body

        nucleus = SKShapeNode(circleOfRadius: 18)
        nucleus.name = "nucleus"
        nucleus.fillColor = UIColor.label.withAlphaComponent(0.16)
        nucleus.strokeColor = UIColor.label.withAlphaComponent(0.28)
        nucleus.lineWidth = 1
        nucleus.position = .zero
        amoeba.addChild(nucleus)

        vacuole = VacuoleNode(radius: 14)
        vacuole.name = "vacuole"
        vacuole.setReduceMotion(reduceMotion)
        vacuole.position = CGPoint(x: 22, y: -12)
        amoeba.addChild(vacuole)

        layoutWorld()
    }

    private func setupParticles() {
        let dust = SKEmitterNode()
        dust.name = "dust"
        dust.particleTexture = SKTexture(image: UIImage(systemName: "circle.fill") ?? UIImage())
        dust.particleBirthRate = 8
        dust.particleColor = UIColor.label.withAlphaComponent(0.15)
        dust.particleLifetime = 7
        dust.particleSpeed = 10
        dust.particleSpeedRange = 8
        dust.particleAlpha = 0.05
        dust.particleAlphaRange = 0.03
        dust.particleScale = 0.02
        dust.particleScaleRange = 0.015
        dust.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        dust.position = CGPoint(x: size.width/2, y: size.height/2)
        dust.zPosition = -10
        worldNode.addChild(dust)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = (lastUpdateTime == 0) ? (1.0/60.0) : (currentTime - lastUpdateTime)
        lastUpdateTime = currentTime

        if !didInitialLayout { layoutWorld() }

        amoeba.tick(dt: dt)
        keepAmoebaInside()

        vacuole.tick(dt: dt, water: water) { [weak self] (drained: CGFloat) in
            guard let self else {
                return
            }
            self.water = max(0, self.water - drained)
            self.applyTheme()
        }

        let waterRise: CGFloat = reduceMotion ? 0.0008 : 0.0012
        water = min(1, water + waterRise * CGFloat(dt * 60))

        let decay: CGFloat = reduceMotion ? 0.00022 : 0.00030
        energy = max(0, energy - decay * CGFloat(dt * 60))
        
        if energy <= 0.0001, !didTriggerEnergyEmpty {
            didTriggerEnergyEmpty = true
            isPaused = true
            onEnergyEmpty?()
        }

        // bacteria spawn
        bacteriaSpawnAcc += dt
        let spawnEvery: TimeInterval = reduceMotion ? 1.8 : 1.35
        if bacteriaSpawnAcc > spawnEvery {
            bacteriaSpawnAcc = 0
            spawnBacteria()
        }

        if water >= 0.98 {
            if worldNode.action(forKey: "panic") == nil {
                let shake = SKAction.sequence([
                    .moveBy(x: 6, y: 0, duration: 0.06),
                    .moveBy(x: -12, y: 0, duration: 0.06),
                    .moveBy(x: 6, y: 0, duration: 0.06)
                ])
                worldNode.run(shake, withKey: "panic")
                run(.sequence([.wait(forDuration: 0.2), .run { [weak self] in self?.resetRun() }]))
            }
        }
    }

    private func keepAmoebaInside() {
        guard let body = amoeba.physicsBody else {
            return
        }
        let pad = amoeba.baseRadius + inset
        let p = amoeba.position

        let clamped = clampPoint(p, padding: pad)
        if clamped != p {
            amoeba.position = clamped
            body.velocity = CGVector(dx: body.velocity.dx * 0.55, dy: body.velocity.dy * 0.55)
        }

        let v = body.velocity
        let speed = sqrt(v.dx*v.dx + v.dy*v.dy)
        if speed > amoebaMaxSpeed {
            let k = amoebaMaxSpeed / max(1, speed)
            body.velocity = CGVector(dx: v.dx * k, dy: v.dy * k)
        }
    }

    private func clampPoint(_ p: CGPoint, padding: CGFloat) -> CGPoint {
        CGPoint(
            x: min(max(p.x, padding), size.width - padding),
            y: min(max(p.y, padding), size.height - padding)
        )
    }

    private func spawnBacteria() {
        let b = BacteriaNode(radius: CGFloat.random(in: 8...12))
        b.position = randomEdgeSpawn()
        worldNode.addChild(b)

        let styleToUse: UIUserInterfaceStyle = (currentStyle == .unspecified) ? .light : currentStyle
        b.applyTheme(traits: UITraitCollection(userInterfaceStyle: styleToUse))

        let target = CGPoint(
            x: CGFloat.random(in: size.width * 0.20...size.width * 0.80),
            y: CGFloat.random(in: size.height * 0.25...size.height * 0.80)
        )

        let move = SKAction.move(to: target, duration: reduceMotion ? 7.0 : 5.4)
        move.timingMode = .easeInEaseOut
        b.run(.sequence([move, .fadeOut(withDuration: 0.25), .removeFromParent()]))
    }

    private func randomEdgeSpawn() -> CGPoint {
        let pad: CGFloat = 16
        let side = Int.random(in: 0...3)
        switch side {
        case 0: return CGPoint(x: CGFloat.random(in: pad...(size.width - pad)), y: -pad)
        case 1: return CGPoint(x: size.width + pad, y: CGFloat.random(in: pad...(size.height - pad)))
        case 2: return CGPoint(x: CGFloat.random(in: pad...(size.width - pad)), y: size.height + pad)
        default: return CGPoint(x: -pad, y: CGFloat.random(in: pad...(size.height - pad)))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { handleTouch(touches) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { handleTouch(touches) }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        let p = t.location(in: worldNode)

        let nodes = worldNode.nodes(at: p)
        if nodes.contains(where: { $0.name == "nucleus" }) { onInfo?(.nucleus); return }
        if nodes.contains(where: { $0.name == "vacuole" }) { onInfo?(.vacuole); return }

        let local = t.location(in: amoeba)
        if amoeba.contains(local) { onInfo?(.membrane) }
    }

    private func handleTouch(_ touches: Set<UITouch>) {
        guard let t = touches.first else {
            return
        }
        let p = t.location(in: worldNode)
        let dir = CGVector(dx: p.x - amoeba.position.x, dy: p.y - amoeba.position.y)
        let len = max(1, sqrt(dir.dx*dir.dx + dir.dy*dir.dy))
        let norm = CGVector(dx: dir.dx/len, dy: dir.dy/len)

        let strength: CGFloat = reduceMotion ? (amoebaForce * 0.7) : amoebaForce
        amoeba.physicsBody?.applyForce(CGVector(dx: norm.dx * strength, dy: norm.dy * strength))
        amoeba.setStretchDirection(norm)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        let amoebaBody = (a.categoryBitMask == PhysicsCategory.amoeba) ? a : b
        let bacteriaBody = (a.categoryBitMask == PhysicsCategory.bacteria) ? a : b

        guard amoebaBody.categoryBitMask == PhysicsCategory.amoeba,
              bacteriaBody.categoryBitMask == PhysicsCategory.bacteria,
              let bacteriaNode = bacteriaBody.node as? BacteriaNode else {
            return
        }

        eat(bacteriaNode)
    }

    private func eat(_ bacteria: BacteriaNode) {
        if bacteria.isEaten { return }
        bacteria.isEaten = true

        bacteria.physicsBody = nil
        bacteria.removeAllActions()

        let toCenter = SKAction.move(to: amoeba.position, duration: reduceMotion ? 0.28 : 0.20)
        toCenter.timingMode = .easeIn

        let shrink = SKAction.scale(to: 0.05, duration: reduceMotion ? 0.28 : 0.20)
        let fade = SKAction.fadeOut(withDuration: reduceMotion ? 0.28 : 0.20)

        bacteria.run(.sequence([
            .group([toCenter, shrink, fade]),
            .removeFromParent()
        ]))

        let energyGain: CGFloat = 0.06
        let waterGain: CGFloat = 0.01

        energy = min(1, energy + energyGain)
        water = min(1, water + waterGain)

        amoeba.gulpPulse()
        vacuole.bump()
    }

    private func publishHUD() {
        onHUD?(.init(
            energy: energy,
            water: water,
            phaseTitle: phaseTitle()
        ))
    }

    private func phaseTitle() -> String {
        if energy < 0.35 { return "Hungry • Eat bacteria" }
        if water > 0.75 { return "Osmoregulation • Vacuole working" }
        if energy > 0.90 { return "Thriving • Tap organelles to learn" }
        return "Move • Eat • Learn"
    }
}

enum PhysicsCategory {
    static let amoeba: UInt32 = 0x1 << 0
    static let bacteria: UInt32 = 0x1 << 1
}
