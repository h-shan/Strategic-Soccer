//
//  GameScene.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright (c) 2016 HS. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background = SKSpriteNode(imageNamed: "SoccerField")
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        background.position = CGPoint(x:midX, y:midY)
        background.size = self.frame.size
        background.zPosition=1
        addChild(background)
        
        let borderBody:SKPhysicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = borderBody
        self.physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        let playerA1 = Player()
        let playerA2 = Player()
        let playerA3 = Player()
        let playerB1 = Player()
        let playerB2 = Player()
        let playerB3 = Player()
        playerA1.position = CGPoint(x:midX*0.3,y:midY*1.5)
        playerA2.position = CGPoint(x:midX*0.3,y:midY*0.5)
        playerA3.position = CGPoint(x:midX*0.7,y:midY)
        playerB1.position = CGPoint(x:midX*1.7,y:midY*1.5)
        playerB2.position = CGPoint(x:midX*1.7,y:midY*0.5)
        playerB3.position = CGPoint(x:midX*1.3,y:midY)
        
        playerA1.physicsBody!.velocity = CGVectorMake(0,0)
        playerA2.physicsBody!.velocity=CGVectorMake(0,0)
        playerA3.physicsBody!.velocity = CGVectorMake(0,0)
        playerB1.physicsBody!.velocity = CGVectorMake(0,0)
        playerB2.physicsBody!.velocity = CGVectorMake(0,0)
        playerB3.physicsBody!.velocity = CGVectorMake(0,0)
        self.addChild(playerA1)
        self.addChild(playerA2)
        self.addChild(playerA3)
        self.addChild(playerB1)
        self.addChild(playerB2)
        self.addChild(playerB3)
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let player:Player = Player()
            player.position = location
            
            //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            //sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(player)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        
        /* Called before each frame is rendered */
    }
}
