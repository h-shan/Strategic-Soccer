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
    var isBright = true
    var highlighted = false
    
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
        } else {
            zRotation = CGFloat(M_PI*0.5)
        }
        self.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width*5/12)
        self.name = name
        self.zPosition = 2
        
        let body:SKPhysicsBody = self.physicsBody!
        body.usesPreciseCollisionDetection = true
        // change back linear damping and friction
        body.linearDamping = CGFloat(defaultFriction)
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
    
    func changeColorDark(){
        if isBright {
            self.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: 0.9, duration: 0))
            isBright = false
        }
    }
    
    func changeColorBright(){
        if !isBright {
            self.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: -0.9, duration: 0))
            isBright = true
        }
    }
    
    func highlight() {
        if !highlighted {
            highlighted = true
            self.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.7, duration: 0))
        }
    }
    
    func unHighlight() {
        if highlighted {
            highlighted = false
            self.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: -0.7, duration: 0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
