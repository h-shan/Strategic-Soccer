//
//  Player.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    var mTeamA:Bool!
    let light = SKLightNode()
    
    init(teamA: Bool){
        mTeamA = teamA
        var texture = SKTexture(imageNamed: "PlayerA")
        if (mTeamA!){
            super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
            lightingBitMask = 1
            light.categoryBitMask = 1
            light.lightColor = UIColor.blackColor()
            self.lightingBitMask = 1
            
        }
        else{
            texture = SKTexture(imageNamed: "PlayerB")
            super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
            light.categoryBitMask = 2
            self.lightingBitMask = 2
            light.lightColor = UIColor.blackColor()
            
        }
        light.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.name = "player"
        self.zPosition = 2
        
        light.enabled = false
        
        addChild(light)
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        
        body.restitution = 1
        body.friction = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
