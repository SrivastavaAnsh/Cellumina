//
//  SignalParticleNode.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 10/02/26.
//


import SpriteKit
import UIKit

final class SignalParticleNode: SKShapeNode {

    private let r: CGFloat

    init(radius: CGFloat) {
        self.r = radius
        super.init()
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        path = UIBezierPath(ovalIn: CGRect(x: -r, y: -r, width: r*2, height: r*2)).cgPath
        fillColor = UIColor.systemOrange.withAlphaComponent(0.55)
        strokeColor = UIColor.systemOrange.withAlphaComponent(0.75)
        lineWidth = 1.5
        glowWidth = 6
        zPosition = 50
    }

    func configurePhysics(signalCategory: UInt32, receptorCategory: UInt32) {
        physicsBody = SKPhysicsBody(circleOfRadius: r + 1)
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0.2
        physicsBody?.angularDamping = 1.0
        physicsBody?.categoryBitMask = signalCategory
        physicsBody?.contactTestBitMask = receptorCategory
        physicsBody?.collisionBitMask = 0
        physicsBody?.usesPreciseCollisionDetection = true
    }

    func wobble() {
        let a = SKAction.sequence([
            .moveBy(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -8...8), duration: 0.10),
            .moveBy(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -8...8), duration: 0.10)
        ])
        a.timingMode = .easeInEaseOut
        run(.repeatForever(a), withKey: "wobble")
    }

    func consume() {
        removeAction(forKey: "wobble")
        physicsBody = nil

        let shrink = SKAction.scale(to: 0.05, duration: 0.14)
        shrink.timingMode = .easeIn
        let fade = SKAction.fadeOut(withDuration: 0.14)

        run(.group([shrink, fade])) { [weak self] in
            self?.removeFromParent()
        }
    }
}
