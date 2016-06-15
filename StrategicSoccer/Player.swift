//
//  Player.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {

    var mXVector:CGFloat
    var mYVector:CGFloat
    
    init(){
        self.mXVector = 2
        self.mYVector = 2
        let texture = SKTexture(imageNamed: "SoccerBall")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = 1
        self.name = "player"
        self.zPosition = 2
        self.physicsBody?.velocity = CGVectorMake(20.0,20.0)
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 1
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(){
        //self.position.x += self.mXVector
        //self.position.y += self.mYVector
        //self.mXVector *= 1
        //self.mYVector *= 1
    }
    
    func collide(p:Player){
        var temp:CGFloat=p.mXVector
        p.mXVector = mXVector
        mXVector = temp
        temp = p.mYVector
        p.mYVector = mYVector
        mYVector = temp
    }

    
    
    
    
}
