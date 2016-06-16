//
//  Ball.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/15/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    
    init() {
        let texture = SKTexture(imageNamed: "Ball")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: texture.size().width/2)
        self.zPosition = 2
        let body = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        body.friction = 0
        body.linearDamping = 0
        body.restitution = 1
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
