//
//  GameScene.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright (c) 2016 HS. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    var selectedPlayer : Player?
    var startPosition : CGPoint?
    var playerSelected : Bool?
    var goalA : Bool?
    var ball: Ball?
    var midY: CGFloat?
    var midX: CGFloat?
    let playerA1 = Player(teamA: true)
    let playerA2 = Player(teamA: true)
    let playerA3 = Player(teamA: true)
    let playerB1 = Player(teamA: false)
    let playerB2 = Player(teamA: false)
    let playerB3 = Player(teamA:false)
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "SoccerField")
        midX = CGRectGetMidX(self.frame)
        midY = CGRectGetMidY(self.frame)
        background.position = CGPoint(x:midX!, y:midY!)
        background.size = self.frame.size
        background.zPosition=1
        addChild(background)
        
        // set rectangular border around screen
        let borderBody:SKPhysicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = borderBody
        self.physicsWorld.contactDelegate = self
        
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        // set goal posts in place
        let goalPostA1:GoalPost = GoalPost()
        let goalPostA2 = GoalPost()
        let goalPostB1 = GoalPost()
        let goalPostB2 = GoalPost()
        goalPostA1.position = CGPoint(x: 50/568*midX!, y: midY!*440/320)
        goalPostA2.position = CGPoint(x: 50/568*midX!, y: midY!*200/320)
        goalPostB1.position = CGPoint(x: 1086/568*midX!, y: midY!*440/320)
        goalPostB2.position = CGPoint(x: 1086/568*midX!, y: midY!*200/320)
        self.addChild(goalPostA1)
        self.addChild(goalPostA2)
        self.addChild(goalPostB1)
        self.addChild(goalPostB2)
        
        // position all 6 players
        
        playerA1.position = CGPoint(x:midX!*0.3,y:midY!*1.5)
        playerA2.position = CGPoint(x:midX!*0.3,y:midY!*0.5)
        playerA3.position = CGPoint(x:midX!*0.7,y:midY!)
        playerB1.position = CGPoint(x:midX!*1.7,y:midY!*1.5)
        playerB2.position = CGPoint(x:midX!*1.7,y:midY!*0.5)
        playerB3.position = CGPoint(x:midX!*1.3,y:midY!)
        
        playerA1.physicsBody!.velocity = CGVectorMake(0,0)
        playerA2.physicsBody!.velocity = CGVectorMake(0,0)
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
        
        // put ball in middle
        ball = Ball()
        ball!.position = CGPoint(x: midX!,y: midY!)
        self.addChild(ball!)
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            
            for child in self.children{
                if node == child && node.name == "player"{
                    selectedPlayer = node as? Player
                    playerSelected = true
                    startPosition = location
                }
            }
        }
    }
        
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        if (playerSelected != nil && playerSelected == true) {
            let xMovement = touches.first!.locationInNode(self).x - startPosition!.x
            let yMovement = touches.first!.locationInNode(self).y - startPosition!.y
            selectedPlayer!.physicsBody!.velocity = CGVectorMake(xMovement, yMovement)
        }
        playerSelected = false
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (200/320 * midY! < ball!.position.y && ball!.position.y < 440/320 * midY!){
            if 0<ball!.position.x && ball!.position.x<50/568*midX!{
                reset(false)
            }
            else if 1086/568*midX!<ball!.position.x {
                reset(true)
            }
        }
        
        /* Called before each frame is rendered */
    }
    func reset(scoreGoalA: Bool){
        // reset position of all players and ball
        
        playerA1.position = CGPoint(x:midX!*0.3,y:midY!*1.5)
        playerA2.position = CGPoint(x:midX!*0.3,y:midY!*0.5)
        playerA3.position = CGPoint(x:midX!*0.7,y:midY!)
        playerB1.position = CGPoint(x:midX!*1.7,y:midY!*1.5)
        playerB2.position = CGPoint(x:midX!*1.7,y:midY!*0.5)
        playerB3.position = CGPoint(x:midX!*1.3,y:midY!)
        
        playerA1.physicsBody!.velocity = CGVectorMake(0,0)
        playerA2.physicsBody!.velocity = CGVectorMake(0,0)
        playerA3.physicsBody!.velocity = CGVectorMake(0,0)
        playerB1.physicsBody!.velocity = CGVectorMake(0,0)
        playerB2.physicsBody!.velocity = CGVectorMake(0,0)
        playerB3.physicsBody!.velocity = CGVectorMake(0,0)
        
        ball!.position = CGPoint(x: midX!,y: midY!)
        ball!.physicsBody!.velocity = CGVectorMake(0,0)
    }
}
