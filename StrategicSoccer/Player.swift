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
        super.init(texture: mTexture, color: UIColor.clear, size: mTexture.size())
    }
    init(teamA: Bool, country: String, sender: GameScene, name: String){
        playerSize = CGSize(width: 120*scalerX, height: 120*scalerX)
        mTeamA = teamA
        mTexture = SKTexture(imageNamed: country)
        //mTexture = SKTexture(image: UIImage(imageLiteral: country))
        super.init(texture: mTexture, color: UIColor.clear, size:playerSize)
        if teamA{
            zRotation = CGFloat(M_PI*1.5)
        }
        else {
            zRotation = CGFloat(M_PI*0.5)
        }
        self.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width*5/12)
        self.name = name
        self.zPosition = 2
        
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        // change back linear damping and friction
        body.linearDamping = 0.6 // 0.4
        body.restitution = 1
        body.friction = 0.1
        body.allowsRotation = false
    }
    init(country: String, sender: Game1Scene){
        playerSize = CGSize(width: 120*scalerX, height: 120*scalerX)
        mTexture = SKTexture(imageNamed: country)
        mTeamA = true
        super.init(texture: mTexture, color: UIColor.clear, size: playerSize)
        zRotation = CGFloat(M_PI*1.5)
        self.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width*5/12)
        self.name = "player"
        self.zPosition = 21
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        // change back linear damping and friction
        body.linearDamping = 0.6 // 0.4
        body.restitution = 1
        body.friction = 0.1
        body.allowsRotation = false
    }
    
    func setLighting(_ bright:Bool){
        if(bright){
            changeColorBright()
        }else{
            changeColorDark()
            
        }
    }
    
    func changeColorBright(){
        self.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: 0.9, duration: 0))
        
    }
    
    func changeColorDark(){
        self.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: -0.9, duration: 0))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
