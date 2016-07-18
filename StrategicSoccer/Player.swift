//
//  Player.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    let mTeamA:Bool
    var mTexture:SKTexture!
    var playerSize: CGSize!
    
    init(){
        mTexture = SKTexture(imageNamed: "BRAZIL")
        mTeamA = false
        super.init(texture: mTexture, color: UIColor.clearColor(), size: mTexture.size())
    }
    init(teamA: Bool, country: String, sender: GameScene){
        playerSize = CGSizeMake(120*scalerX, 120*scalerX)
        mTeamA = teamA
        mTexture = SKTexture(imageNamed: country)
        //mTexture = SKTexture(image: UIImage(imageLiteral: country))
        super.init(texture: mTexture, color: UIColor.clearColor(), size:playerSize)
        if teamA{
            zRotation = CGFloat(M_PI*1.5)
        }
        else {
            zRotation = CGFloat(M_PI*0.5)
        }
        self.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width*5/12)
        self.name = "player"
        self.zPosition = 2
        
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        // change back linear damping and friction
        body.linearDamping = 0.3
        body.restitution = 1
        body.friction = 0.1
        body.allowsRotation = false
    }
    init(country: String, sender: Game1Scene){
        playerSize = CGSizeMake(120*scalerX, 120*scalerX)
        mTexture = SKTexture(imageNamed: country)
        mTeamA = true
        super.init(texture: mTexture, color: UIColor.clearColor(), size: playerSize)
        zRotation = CGFloat(M_PI*1.5)
        self.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width*5/12)
        self.name = "player"
        self.zPosition = 2
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = 1
        // change back linear damping and friction
        body.linearDamping = 0.3
        body.restitution = 1
        body.friction = 0.1
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
        self.runAction(SKAction.colorizeWithColor(UIColor.grayColor(), colorBlendFactor: 0.9, duration: 0.00001))
        
    }
    
    func changeColorDark(){
        self.runAction(SKAction.colorizeWithColor(UIColor.grayColor(), colorBlendFactor: -0.9, duration: 0.00001))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
