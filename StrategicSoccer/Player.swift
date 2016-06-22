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
    var storedVelocity:CGVector?
    
    
    init(teamA: Bool){
        mTeamA = teamA
        var texture = SKTexture(imageNamed: "PlayerTaiwan")
        if (mTeamA!){
            super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        }
        else{
            texture = SKTexture(imageNamed: "PlayerUSA")
            super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        }
        self.physicsBody = SKPhysicsBody(circleOfRadius: texture.size().width*5/12)
        self.name = "player"
        self.zPosition = 2
        
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        
        body.restitution = 1
        body.friction = 1
        body.allowsRotation = false
    }
    
    func setLighting(bright:Bool){
        if(bright){
            changeColorBright()
        }else{
            changeColorDark()
            
        }
    }
    
    func changeColorBright(){
        self.runAction(SKAction.colorizeWithColor(UIColor.grayColor(), colorBlendFactor: 0.7, duration: 0.00001))
        
    }
    
    func changeColorDark(){
        self.runAction(SKAction.colorizeWithColor(UIColor.grayColor(), colorBlendFactor: -0.7, duration: 0.00001))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
