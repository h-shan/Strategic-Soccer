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
    let playerB3 = Player(teamA: false)
    var players: [Player]?
    
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
    
    let lightA1 = SKLightNode()
    let lightA2 = SKLightNode()
    let lightA3 = SKLightNode()
    let lightB1 = SKLightNode()
    let lightB2 = SKLightNode()
    let lightB3 = SKLightNode()
    
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
        
        players = [playerA1, playerA2, playerA3, playerB1, playerB2, playerB3]
        
        for node in players!{
            self.addChild(node)
        }
        
        // put ball in middle
        ball = Ball()
        ball!.position = CGPoint(x: midX!,y: midY!)
        self.addChild(ball!)
        
        // set pause button
        pause.position = CGPoint(x: 50/568*midX!, y:50/320*midY!)
        pause.zPosition = 1.5
        pause.name = "pause"
        addChild(pause)
        
        // set dimming
        playerA1.lightingBitMask = 1
        lightA1.categoryBitMask = 1
        lightA1.position = playerA1.position
        lightA1.lightColor = UIColor.blackColor()
        addChild(lightA1)
        
        playerA2.lightingBitMask = 1
        lightA2.categoryBitMask = 1
        lightA2.position = playerA2.position
        lightA2.lightColor = UIColor.blackColor()
        addChild(lightA2)
        
        playerA3.lightingBitMask = 1
        lightA3.categoryBitMask = 1
        lightA3.position = playerA3.position
        lightA3.lightColor = UIColor.blackColor()
        addChild(lightA3)
        
        playerB1.lightingBitMask = 2
        lightB1.categoryBitMask = 2
        lightB1.position = playerB1.position
        lightB1.lightColor = UIColor.blackColor()
        addChild(lightB1)
        
        playerB2.lightingBitMask = 2
        lightB2.categoryBitMask = 2
        lightB2.position = playerB2.position
        lightB2.lightColor = UIColor.blackColor()
        addChild(lightB2)
        
        playerB3.lightingBitMask = 2
        lightB3.categoryBitMask = 2
        lightB3.position = playerB3.position
        lightB3.lightColor = UIColor.blackColor()
        addChild(lightB3)
        
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
        {
       /* Called when a touch begins */
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            if startPaused {
                if node == pause {
                    endPaused = true
                }
            }else{
                if node is Player{
                    let touchedPlayer = (node as! Player)
                    if touchedPlayer.mTeamA! == turnA {
                        selectedPlayer = touchedPlayer
                        playerSelected = true
                        startPosition = location
                        turnA = !turnA
                    }
                }
                if node.name == "pause"{
                    startPaused = true
                }
            }
        }
    }
        
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        if (startPaused && !endPaused){
            if (nodeAtPoint(touches.first!.locationInNode(self))) == pause {
                score.text = "PAUSED"
                storeVelocities()
                setDynamicStates(false)
            }
        }
        else if (startPaused && endPaused){
            startPaused = false; endPaused = false
            score.text = ""
            setDynamicStates(true)
            retrieveVelocities()
        }
        if (playerSelected != nil && playerSelected == true) {
            turnA = !turnA
            let xMovement = 1.5*(touches.first!.locationInNode(self).x - startPosition!.x)
            let yMovement = 1.5*(touches.first!.locationInNode(self).y - startPosition!.y)
            
            selectedPlayer!.physicsBody!.velocity = CGVectorMake(xMovement, yMovement)
        }
        
        playerSelected = false
    }
   
    override func update(currentTime: CFTimeInterval) {
        lightA1.position = playerA1.position
        lightA2.position = playerA2.position
        lightA3.position = playerA3.position
        lightB1.position = playerB1.position
        lightB2.position = playerB2.position
        lightB3.position = playerB3.position
        if (!turnA){
            lightA1.enabled = true
            lightA2.enabled = true
            lightA3.enabled = true
            lightB1.enabled = false
            lightB2.enabled = false
            lightB3.enabled = false
        }
        else{
            lightA1.enabled = false
            lightA2.enabled = false
            lightA3.enabled = false
            lightB1.enabled = true
            lightB2.enabled = true
            lightB3.enabled = true
            
        }
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
        
        setDynamicStates(false)
        
        if scoreGoal{
            scoreA+=1
            turnA = false
        }
        else{
            scoreB+=1
            turnA = true
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
        
        for child in self.children{
            if child is Player{
                child.physicsBody!.velocity = CGVectorMake(0,0)
            }
        }
        
        ball!.position = CGPoint(x: midX!,y: midY!)
        ball!.physicsBody!.velocity = CGVectorMake(0,0)
    }
    
    func twoSeconds(){
        score.text = ""
        setDynamicStates(true)
    }
    
    func setDynamicStates(isDynamic: Bool){
        for player in self.players!{
            player.physicsBody!.dynamic = isDynamic
        }
        ball?.physicsBody!.dynamic = isDynamic
    }
    
    func storeVelocities(){
        for player in self.players!{
            player.storedVelocity = player.physicsBody!.velocity
        }
        ball!.storedVelocity = ball!.physicsBody!.velocity
    }
    
    func retrieveVelocities(){
        for player in self.players!{
            player.physicsBody!.velocity = player.storedVelocity!
        }
        ball!.physicsBody!.velocity = ball!.storedVelocity!
    }
    
    
}
