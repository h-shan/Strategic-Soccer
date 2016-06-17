//
//  GameScene.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright (c) 2016 HS. All rights reserved.
//

import SpriteKit
import Foundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    var selectedPlayer : Player?
    var startPosition : CGPoint?
    var playerSelected = false
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
    
    let gameTimer = TimerM()
    let clock = SKLabelNode(fontNamed: "Georgia")
    var gameTime: NSTimeInterval?
    var baseTime = 180.1
    
    let mode: Mode
    
    
    let pause = SKSpriteNode(texture: SKTexture(imageNamed: "Pause"), color: UIColor.clearColor(), size: SKTexture(imageNamed: "Pause").size())

    var turnA = true
    var startPaused = false
    var endPaused = false
    var scoreA = 0
    var scoreB = 0
    let score = SKLabelNode(fontNamed: "Georgia")
    
    var timer: NSTimer?
    init(size: CGSize, mode: Mode){
        self.mode = mode
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        updateLighting()
        
        restartTimer()
        
        // set timer for threeMinute
        
        if (mode == Mode.threeMinute){
            gameTime = 180
            // set up clock
            clock.text = gameTimer.secondsToString(gameTime!)
            clock.fontSize = 15
            clock.position = CGPoint(x: midX!, y: 7/4*midY!)
            clock.zPosition = 1.5
            clock.fontColor = UIColor.blackColor()
            gameTimer.start()
            addChild(clock)
            updateTime()
        }
        
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
                        selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.4, duration: 0.00001))
                        
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
                timer?.invalidate()
                paused = true
                if mode == Mode.threeMinute{
                    baseTime = gameTime!
                }
            }
        }
        else if (startPaused && endPaused){
            startPaused = false; endPaused = false
            score.text = ""
            setDynamicStates(true)
            retrieveVelocities()
            restartTimer()
            gameTimer.start()
            paused = false
        }
        if (playerSelected == true) {
            
            let xMovement = 1.5*(touches.first!.locationInNode(self).x - startPosition!.x)
            let yMovement = 1.5*(touches.first!.locationInNode(self).y - startPosition!.y)
            
            selectedPlayer!.physicsBody!.velocity = CGVectorMake(xMovement, yMovement)
            switchTurns()
            
        }
        
        playerSelected = false
    }
    
    func updateLighting(){
        for player in players!{
            if playerSelected && player == selectedPlayer!{
                player.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: -0.4, duration: 0.00001))
                playerSelected = false
            }
            player.setLighting(player.mTeamA != turnA)
            
        }
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
        
        setDynamicStates(false)
        timer?.invalidate()
        updateLighting()
        paused = true
        if scoreGoal{
            scoreA+=1
            turnA = false
        }
        else{
            scoreB+=1
            turnA = true
        }
        if mode == Mode.tenPoints{
            if scoreA == 10 || scoreB == 10 {
                endGame()
            }
            else{
                score.text = String.localizedStringWithFormat("%d - %d", scoreA, scoreB)

            }
        }
        else{
            score.text = String.localizedStringWithFormat("%d - %d", scoreA, scoreB)
        }
        _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(twoSeconds), userInfo: nil, repeats: false)
        restartTimer()
        
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
        ball!.physicsBody!.angularVelocity = 0
    }
    
    func twoSeconds(){
        score.text = ""
        setDynamicStates(true)
        paused = false
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
    func switchTurns(){
        turnA = !turnA
        if playerSelected == true {
            playerSelected = false
        }
        restartTimer()
        updateLighting()
    }
    func restartTimer(){
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(switchTurns), userInfo: nil, repeats: false)
    }
    func updateTime(){
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(showTime), userInfo: nil, repeats: true)
    }
    func showTime(){
        if !paused {
            gameTime = baseTime - gameTimer.stop()
            if (gameTime<=0){
                endGame()
            }
            clock.text = gameTimer.secondsToString(gameTime!)
        }
        
    }
    func endGame(){
        if scoreA > scoreB {
            score.text = "Player A Wins"
        }
        else if scoreB > scoreA {
            score.text = "Player B Wins"
        }
        else{
            score.text = "It's a Tie!"
        }
        _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(goBackToTitle), userInfo: nil, repeats: false)
    }
    func goBackToTitle (){
        let nextScene = TitleScene(size: scene!.size)
        scene?.view?.presentScene(nextScene)
    }
    
}
