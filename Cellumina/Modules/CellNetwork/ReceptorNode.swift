//
//  ReceptorNode.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 10/02/26.
//


import SpriteKit
import UIKit

final class ReceptorNode: SKNode {

    weak var ownerCell: SignalingCellNode?

    private let shape: SKShapeNode
    private let baseRadius: CGFloat

    init(owner: SignalingCellNode, radius: CGFloat) {
        self.ownerCell = owner
        self.baseRadius = radius
        self.shape = SKShapeNode(circleOfRadius: radius)
        super.init()
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        shape.fillColor = UIColor.white.withAlphaComponent(0.14)
        shape.strokeColor = UIColor.white.withAlphaComponent(0.45)
        shape.lineWidth = 2
        shape.glowWidth = 0
        addChild(shape)
    }

    func configurePhysics(receptorCategory: UInt32) {
        physicsBody = SKPhysicsBody(circleOfRadius: baseRadius + 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = receptorCategory
        physicsBody?.contactTestBitMask = 0
        physicsBody?.collisionBitMask = 0
    }

    func activate() {
        let on = SKAction.run { [weak self] in
            guard let self else {
                return
            }
            self.shape.fillColor = UIColor.systemPink.withAlphaComponent(0.30)
            self.shape.strokeColor = UIColor.systemPink.withAlphaComponent(0.70)
            self.shape.glowWidth = 8
        }

        let bump = SKAction.sequence([
            .scale(to: 1.25, duration: 0.08),
            .scale(to: 1.0, duration: 0.12)
        ])

        let off = SKAction.run { [weak self] in
            guard let self else {
                return
            }
            self.shape.fillColor = UIColor.label.withAlphaComponent(0.10)
            self.shape.strokeColor = UIColor.label.withAlphaComponent(0.25)
            self.shape.glowWidth = 0
        }

        run(.sequence([on, bump, .wait(forDuration: 0.18), off]))
    }
}
