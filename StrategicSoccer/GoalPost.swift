//
//  GoalPost.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/15/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class GoalPost: SKSpriteNode {
    
    init(){
        let texture = SKTexture(imageNamed: "GoalPost")
        let actualSize = CGSizeMake(texture.size().width*0.7, texture.size().height*0.8)
        super.init(texture: texture, color: UIColor.redColor(), size: actualSize)
        
        self.name = "goalPost"
        self.zPosition=2
        self.physicsBody = SKPhysicsBody(rectangleOfSize: actualSize)
        
        let body = self.physicsBody!
        body.dynamic = false
        body.categoryBitMask = 1
        body.usesPreciseCollisionDetection = true
        body.restitution = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
