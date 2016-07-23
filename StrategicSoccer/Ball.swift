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
    init(){
        super.init(texture: mTexture, color: UIColor.clearColor(),size:mTexture.size())
    }
    init(scene: SKScene) {
        radius = 45*scalerX
        let ballSize = CGSizeMake(radius,radius)
        super.init(texture: mTexture, color: UIColor.clearColor(), size: ballSize)
        self.name="ball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: ballSize.width/2)
        self.zPosition = 2
        let body = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.linearDamping = 0.3
        body.angularDamping = 0
        body.restitution = 1
        body.friction = 1
        body.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
