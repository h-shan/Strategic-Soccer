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
        background.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        background.size = self.frame.size
        background.zPosition=1
        addChild(background)
        
        let borderBody:SKPhysicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = borderBody
        self.physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
    }
    
//    func didBeginContact(contact: SKPhysicsContact){
//        let firstNode = contact.bodyA.node as! SKSpriteNode
//        let secondNode = contact.bodyB.node as! SKSpriteNode
//        if(firstNode.name == "player"){
//            let firstP = firstNode as! Player
//            
//        }
//        if(secondNode.name=="player"){
//            let secondP = secondNode as! Player
//        }
//        
//        
//    }
    
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
        for node in self.children{
            if node.name == "player"{
                let p = node as! Player
                p.move()
            }
            
        }
        /* Called before each frame is rendered */
    }
}
