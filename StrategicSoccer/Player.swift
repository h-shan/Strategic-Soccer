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
    var mTexture:SKTexture
    
    init(){
        mTexture = SKTexture(imageNamed: "Brazil")
        super.init(texture: mTexture, color: UIColor.clearColor(), size: mTexture.size())
    }
    init(teamA: Bool, country: String, sender: GameScene){
        let playerSize = CGSizeMake(120/568*sender.midX!, 120/320*sender.midY!)
        mTeamA = teamA
        mTexture = SKTexture(imageNamed: country)
        super.init(texture: mTexture, color: UIColor.clearColor(), size:playerSize)
        zRotation = 3.1415*0.5
        self.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width*5/12)
        self.name = "player"
        self.zPosition = 2
        
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        body.linearDamping = 0.5
        body.restitution = 1
        body.friction = 0.6
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
