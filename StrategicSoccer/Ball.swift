//
//  Ball.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/15/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    
    var storedVelocity:CGVector?
    
    init() {
        let texture = SKTexture(imageNamed: "Ball")
        let actualSize = CGSizeMake(texture.size().width*0.85, texture.size().height*0.85)
        super.init(texture: texture, color: UIColor.clearColor(), size: actualSize)
        
        self.name="ball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: actualSize.width/2)
        self.zPosition = 2
        let body = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        
        body.restitution = 1
        body.friction = 1
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
