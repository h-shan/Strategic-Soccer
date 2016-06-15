//
//  Player.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    
    init(){
        
        let texture = SKTexture(imageNamed: "Player")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2*0.95)
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        self.name = "player"
        self.zPosition = 2
        body.velocity = CGVectorMake(50.0,50.0)
        body.friction = 0
        body.linearDamping = 0
        body.restitution = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
