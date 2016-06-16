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
    let pause = SKSpriteNode(texture: SKTexture(imageNamed: "Pause"), color: UIColor.clearColor(), size: SKTexture(imageNamed: "Pause").size())
    
    var turnA = true
    var startPaused = false
    var endPaused = false
    var scoreA = 0
    var scoreB = 0
    let score = SKLabelNode(fontNamed: "Georgia")
    
    var velocityA1: CGVector?
    var velocityA2: CGVector?
    var velocityA3: CGVector?
    var velocityB1: CGVector?
    var velocityB2: CGVector?
    var velocityB3: CGVector?
    var velocityBall: CGVector?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "SoccerField")
        midX = CGRectGetMidX(self.frame)
        midY = CGRectGetMidY(self.frame)
       
        
        
        score.fontSize = 50
        score.fontColor = UIColor.blackColor()
        score.position = CGPoint(x: midX!, y: 1.5*midY!)
        score.zPosition = 2
        
        addChild(score)
        
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
        let goalPostA1 = GoalPost()
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
        
//        playerA1.physicsBody!.velocity = CGVectorMake(0,0)
//        playerA2.physicsBody!.velocity = CGVectorMake(0,0)
//        playerA3.physicsBody!.velocity = CGVectorMake(0,0)
//        playerB1.physicsBody!.velocity = CGVectorMake(0,0)
//        playerB2.physicsBody!.velocity = CGVectorMake(0,0)
//        playerB3.physicsBody!.velocity = CGVectorMake(0,0)
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
        
        // set pause button
        pause.position = CGPoint(x: 50/568*midX!, y:50/320*midY!)
        pause.zPosition = 1.5
        pause.name = "pause"
        addChild(pause)
        
        
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            if startPaused {
                if node == pause {
                    endPaused = true
                }
            }
            else{
                for child in self.children{
                    if node == child && node.name == "player"{
                        let touchedPlayer = (node as! Player)
                        if touchedPlayer.mTeamA! == turnA {
                            selectedPlayer = touchedPlayer
                            playerSelected = true
                            startPosition = location
                            turnA = !turnA
                        }
                    }
                    if node == child && child.name == "pause"{
                        startPaused = true
                    }
                }
            }
        }
    }
        
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        if (startPaused && !endPaused){
            if (nodeAtPoint(touches.first!.locationInNode(self))) == pause {
                score.text = "PAUSED"
                velocityA1 = playerA1.physicsBody!.velocity
                velocityA2 = playerA2.physicsBody!.velocity
                velocityA3 = playerA3.physicsBody!.velocity
                velocityB1 = playerB1.physicsBody!.velocity
                velocityB2 = playerB2.physicsBody!.velocity
                velocityB3 = playerB3.physicsBody!.velocity
                velocityBall = ball?.physicsBody!.velocity
                
                playerA1.physicsBody!.dynamic = false
                playerA2.physicsBody!.dynamic = false
                playerA3.physicsBody!.dynamic = false
                playerB1.physicsBody!.dynamic = false
                playerB2.physicsBody!.dynamic = false
                playerB3.physicsBody!.dynamic = false
                ball?.physicsBody!.dynamic = false
                
            }
        }
        else if (startPaused && endPaused){
            startPaused = false; endPaused = false
            score.text = ""
            playerA1.physicsBody!.dynamic = true
            playerA2.physicsBody!.dynamic = true
            playerA3.physicsBody!.dynamic = true
            playerB1.physicsBody!.dynamic = true
            playerB2.physicsBody!.dynamic = true
            playerB3.physicsBody!.dynamic = true
            ball?.physicsBody!.dynamic = true
            playerA1.physicsBody!.velocity = velocityA1!
            playerA2.physicsBody!.velocity = velocityA2!
            playerA3.physicsBody!.velocity = velocityA3!
            playerB1.physicsBody!.velocity = velocityB1!
            playerB2.physicsBody!.velocity = velocityB2!
            playerB3.physicsBody!.velocity = velocityB3!
            ball!.physicsBody!.velocity = velocityBall!
        }
        if (playerSelected != nil && playerSelected == true) {
            let xMovement = 1.5*(touches.first!.locationInNode(self).x - startPosition!.x)
            let yMovement = 1.5*(touches.first!.locationInNode(self).y - startPosition!.y)
            
            selectedPlayer!.physicsBody!.velocity = CGVectorMake(xMovement, yMovement)
        }
        playerSelected = false
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (200/320 * midY! < ball!.position.y && ball!.position.y < 440/320 * midY!){
            if 0<ball!.position.x && ball!.position.x<50/568*midX!{
                self.reset(false)
            }
            else if 1086/568*midX! < ball!.position.x {
                self.reset(true)
            }
        }
        
        /* Called before each frame is rendered */
    }
    func reset(scoreGoal: Bool){
        // reset position of all players and ball
        playerA1.physicsBody!.dynamic = false
        playerA2.physicsBody!.dynamic = false
        playerA3.physicsBody!.dynamic = false
        playerB1.physicsBody!.dynamic = false
        playerB2.physicsBody!.dynamic = false
        playerB3.physicsBody!.dynamic = false
        
        if scoreGoal{
            scoreA+=1
        }
        else{
            scoreB+=1
        }
        if scoreA == 10 {
            score.text = "Player A Wins"
            scoreA = 0
            scoreB = 0
            _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(twoSeconds), userInfo: nil, repeats: false)
        }
        else if scoreB == 10{
            score.text = "Player B Wins"
            scoreA = 0
            scoreB = 0
            _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(twoSeconds), userInfo: nil, repeats: false)
        }
        else{ _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(twoSeconds), userInfo: nil, repeats: false)
            score.text = "\(scoreA) - \(scoreB)"
        }
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
    func twoSeconds(){
        score.text = ""
        playerA1.physicsBody!.dynamic = true
        playerA2.physicsBody!.dynamic = true
        playerA3.physicsBody!.dynamic = true
        playerB1.physicsBody!.dynamic = true
        playerB2.physicsBody!.dynamic = true
        playerB3.physicsBody!.dynamic = true
    }
    
    
}
