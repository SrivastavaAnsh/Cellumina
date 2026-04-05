//
//  BacteriaNode.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import SpriteKit
import UIKit

final class BacteriaNode: SKNode {

    var isEaten: Bool = false
    
    private let shape = SKShapeNode()
    private let radius: CGFloat
    

    init(radius: CGFloat) {
        self.radius = radius
        super.init()

        shape.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius * 0.85, width: radius * 2, height: radius * 1.7), transform: nil)
        shape.fillColor = UIColor.label.withAlphaComponent(0.14)
        shape.strokeColor = UIColor.label.withAlphaComponent(0.28)
        shape.lineWidth = 1
        addChild(shape)

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = true
        body.affectedByGravity = false
        body.linearDamping = 0
        body.categoryBitMask = PhysicsCategory.bacteria
        body.contactTestBitMask = PhysicsCategory.amoeba
        body.collisionBitMask = 0
        physicsBody = body

        let wiggle = SKAction.sequence([
            .moveBy(x: 3, y: 2, duration: 0.3),
            .moveBy(x: -2, y: -3, duration: 0.35),
            .moveBy(x: -2, y: 2, duration: 0.32),
            .moveBy(x: 1, y: -1, duration: 0.28)
        ])
        run(.repeatForever(wiggle))
    }
    
    func applyTheme(traits: UITraitCollection) {
        shape.fillColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.14)
        shape.strokeColor = UIColor.label.resolvedColor(with: traits).withAlphaComponent(0.28)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
