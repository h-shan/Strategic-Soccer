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
    var ball = Ball()
    var midY: CGFloat?
    var midX: CGFloat?
    var playerA1 = Player()
    var playerA2 = Player()
    var playerA3 = Player()
    var playerB1 = Player()
    var playerB2 = Player()
    var playerB3 = Player()
    var players: [Player]?
    var gameEnded = false
    var viewController: TitleViewController!
    
    let gameTimer = Timer()
    let clock = SKLabelNode(fontNamed: "Georgia")
    var gameTime: NSTimeInterval?
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
    
    var moveTimer:Timer?
    
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
        score.zPosition = 4
        
        addChild(score)
        
        background.position = CGPoint(x:midX!, y:midY!)
        background.size = self.frame.size
        background.zPosition=1
        addChild(background)
        
        // set rectangular border around screen
        let borderBody:SKPhysicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.linearDamping = 0
        self.physicsBody = borderBody
        self.physicsWorld.contactDelegate = self
        
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        // make soccer net
        let netTexture = SKTexture(imageNamed: "SoccerNet")
        let netSize = CGSize(width: 80/568*midX!, height: 240/320*midY!)
        let leftSoccerNet = SKSpriteNode(texture: netTexture, size: netSize)
        let rightSoccerNet = SKSpriteNode(texture: netTexture, size: netSize)
        rightSoccerNet.position = CGPoint(x: 1096/568*midX!, y: midY!)
        leftSoccerNet.position = CGPoint(x:40/568*midX!, y: midY!)
        rightSoccerNet.zPosition = 3
        leftSoccerNet.zPosition = 3
        addChild(leftSoccerNet)
        addChild(rightSoccerNet)
        
        // set goal posts in place
        
        let goalPostA1 = GoalPost(sender: self)
        let goalPostA2 = GoalPost(sender: self)
        let goalPostB1 = GoalPost(sender: self)
        let goalPostB2 = GoalPost(sender: self)
        goalPostA1.position = CGPoint(x: 50/568*midX!, y: midY!*440/320)
        goalPostA2.position = CGPoint(x: 50/568*midX!, y: midY!*200/320)
        goalPostB1.position = CGPoint(x: 1086/568*midX!, y: midY!*440/320)
        goalPostB2.position = CGPoint(x: 1086/568*midX!, y: midY!*200/320)
        self.addChild(goalPostA1)
        self.addChild(goalPostA2)
        self.addChild(goalPostB1)
        self.addChild(goalPostB2)
        
        playerA1 = Player(teamA: true, sender: self)
        playerA2 = Player(teamA: true, sender: self)
        playerA3 = Player(teamA: true, sender: self)
        playerB1 = Player(teamA: false, sender: self)
        playerB2 = Player(teamA: false, sender: self)
        playerB3 = Player(teamA: false, sender: self)
        
        players = [playerA1, playerA2, playerA3, playerB1, playerB2, playerB3]
        
        for node in players!{
            self.addChild(node)
        }
        
        // put ball in middle
        
        
        ball = Ball(scene: self)
        setPosition()
        self.addChild(ball)
        
        // set pause button
        pause.position = CGPoint(x: 50/568*midX!, y:50/320*midY!)
        pause.zPosition = 1.5
        pause.name = "pause"
        addChild(pause)
        
        updateLighting()
        moveTimer = Timer()
        moveTimer?.restart()
        
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
                if (node is Player && !paused){
                    let touchedPlayer = (node as! Player)
                    if touchedPlayer.mTeamA! == turnA {
                        selectedPlayer = touchedPlayer
                        playerSelected = true
                        startPosition = location
                        selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.4, duration: 0.00001))
                        
                    }
                }
                else{
                    if !paused{
                    for player in players!{
                        if player.mTeamA! == turnA{
                            if distance(player.position, point2: location) < player.size.width*1.5 {
                                selectedPlayer = player
                                playerSelected = true
                                startPosition = player.position
                                selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.4, duration: 0.00001))
                            }
                        }
                        }
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
                moveTimer?.pause()
                if(mode == Mode.threeMinute){
                    gameTimer.pause()
                }
            }
        }
        else if (startPaused && endPaused){
            startPaused = false; endPaused = false
            score.text = ""
            setDynamicStates(true)
            retrieveVelocities()
            if(mode == Mode.threeMinute){
                gameTimer.start()
            }
            paused = false
            moveTimer?.start()
        }
        if (playerSelected == true) {
            
            let xMovement = 2*(touches.first!.locationInNode(self).x - startPosition!.x)
            let yMovement = 2*(touches.first!.locationInNode(self).y - startPosition!.y)
            
            selectedPlayer!.physicsBody!.velocity = CGVectorMake(xMovement, yMovement)
            playerSelected = false
            switchTurns()
            
        }
        
        playerSelected = false
    }
    
    func updateLighting(){
        for player in players!{
            player.setLighting(player.mTeamA != turnA)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        if (200/320 * midY! < ball.position.y && ball.position.y < 440/320 * midY!){
            if 0<ball.position.x && ball.position.x<50/568*midX!{
                
                if !turnA {
                    switchTurns()
                }
                self.reset(false)
            }
            else if 1086/568*midX! < ball.position.x {
                
                if turnA {
                    switchTurns()
                }
                self.reset(true)
            }
        }
        
        if(moveTimer!.getElapsedTime() > 5){
            switchTurns()
        }
        if !gameEnded{
            showTime()
        }
        /* Called before each frame is rendered */
    }
    
    func reset(scoreGoal: Bool){
        // reset position of all players and ball
        
        if playerSelected{
            playerSelected = false
            selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.grayColor(), colorBlendFactor: -0.7, duration: 0.00001))
        }
        moveTimer?.restart()
        
        if scoreGoal{
            scoreA+=1
        }
        else if !scoreGoal{
            scoreB+=1
        }
        setDynamicStates(false)
        paused = true
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
        if mode == Mode.threeMinute{
            gameTimer.pause()
        }
        
        _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(twoSeconds), userInfo: nil, repeats: false)
        
        
        
    }
    
    func twoSeconds(){
        score.text = ""
        setDynamicStates(true)
        paused = false
        moveTimer?.restart()
        if mode == Mode.threeMinute{
            
            gameTimer.start()
            
        }
        setPosition()
        ball.physicsBody!.velocity = CGVectorMake(0,0)
        ball.physicsBody!.angularVelocity = 0
    }
    
    func setDynamicStates(isDynamic: Bool){
        for player in self.players!{
            player.physicsBody!.dynamic = isDynamic
        }
        ball.physicsBody!.dynamic = isDynamic
    }
    
    func storeVelocities(){
        for player in self.players!{
            player.storedVelocity = player.physicsBody!.velocity
        }
        ball.storedVelocity = ball.physicsBody!.velocity
    }
    
    func retrieveVelocities(){
        for player in self.players!{
            player.physicsBody!.velocity = player.storedVelocity!
        }
        ball.physicsBody!.velocity = ball.storedVelocity!
    }
    
    func switchTurns(){
        turnA = !turnA
        
        if playerSelected == true {
            playerSelected = false
        }
        updateLighting()
        moveTimer?.restart()
        
    }
    
    
    func showTime(){
        if !paused {
            gameTime = 5.1 - gameTimer.getElapsedTime()
            if (gameTime<=0){
                clock.text = "0:00"
                
                gameTimer.pause()
                moveTimer?.pause()
                endGame()
            }else{
                clock.text = gameTimer.secondsToString(gameTime!)
            }
        }
        
    }
    
    func endGame(){
        gameEnded = true
        setDynamicStates(false)
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
        gameTimer.elapsedTime = 0
    }
    func goBackToTitle(){
        viewController.showAll()
        view?.presentScene(viewController.background)
    }
    
    func setPosition(){
        playerA1.position = CGPoint(x:midX!*0.3,y:midY!*1.5)
        playerA2.position = CGPoint(x:midX!*0.3,y:midY!*0.5)
        playerA3.position = CGPoint(x:midX!*0.7,y:midY!)
        playerB1.position = CGPoint(x:midX!*1.7,y:midY!*1.5)
        playerB2.position = CGPoint(x:midX!*1.7,y:midY!*0.5)
        playerB3.position = CGPoint(x:midX!*1.3,y:midY!)
        ball.position = CGPoint(x: midX!,y: midY!)
    }
    func distance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        let distX = point1.x-point2.x
        let distY = point1.y-point2.y
        return sqrt(distX*distX + distY*distY)
    }
}
