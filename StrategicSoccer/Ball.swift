//
//  Ball.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/15/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    let mTexture = SKTexture(imageNamed: "Ball")
    var storedVelocity:CGVector?
    var radius:CGFloat = 0
    
    init() {
        radius = 45*scalerX
        let ballSize = CGSize(width: radius,height: radius)
        super.init(texture: mTexture, color: UIColor.clear, size: ballSize)
        self.name = "ball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: ballSize.width/2)
        self.zPosition = 2
        let body = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.linearDamping = CGFloat(defaultFriction)
        body.angularDamping = 0
        body.restitution = 1
        body.friction = 1 // 1
        body.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
