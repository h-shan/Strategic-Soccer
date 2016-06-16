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
    
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "SoccerField")
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        background.position = CGPoint(x:midX, y:midY)
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
        goalPostA1.position = CGPoint(x: 50/568*midX, y: midY*440/320)
        goalPostA2.position = CGPoint(x: 50/568*midX, y: midY*200/320)
        goalPostB1.position = CGPoint(x: 1086/568*midX, y: midY*440/320)
        goalPostB2.position = CGPoint(x: 1086/568*midX, y: midY*200/320)
        self.addChild(goalPostA1)
        self.addChild(goalPostA2)
        self.addChild(goalPostB1)
        self.addChild(goalPostB2)
        
        // initilaize and position all 6 players
        let playerA1 = Player(teamA: true)
        let playerA2 = Player(teamA: true)
        let playerA3 = Player(teamA: true)
        let playerB1 = Player(teamA: false)
        let playerB2 = Player(teamA: false)
        let playerB3 = Player(teamA: false)
        
        playerA1.position = CGPoint(x:midX*0.3,y:midY*1.5)
        playerA2.position = CGPoint(x:midX*0.3,y:midY*0.5)
        playerA3.position = CGPoint(x:midX*0.7,y:midY)
        playerB1.position = CGPoint(x:midX*1.7,y:midY*1.5)
        playerB2.position = CGPoint(x:midX*1.7,y:midY*0.5)
        playerB3.position = CGPoint(x:midX*1.3,y:midY)
        
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
        let ball = Ball()
        ball.position = CGPoint(x: midX,y: midY)
        self.addChild(ball)
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            for player in self.children{
                let player = player as? Player
                if let nPlayer = player{
                    let x2 = (location.x-nPlayer.position.x)*(location.x-nPlayer.position.x)
                    let y2 = (location.y-nPlayer.position.y)*(location.y-nPlayer.position.y)
                
                    if nPlayer.name == "player" && sqrt(x2+y2) < nPlayer.size.width/2{
                            selectedPlayer = nPlayer
                            startPosition = location
                            playerSelected = true
                        }
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
        
        
        /* Called before each frame is rendered */
    }
}
