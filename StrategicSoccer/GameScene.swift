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
    var playerA4 = Player()
    var playerB1 = Player()
    var playerB2 = Player()
    var playerB3 = Player()
    var playerB4 = Player()
    var players: [Player]?
    var gameEnded = false
    var viewController: GameViewController!
    var goalAccounted = false
    
    var countryA:String!
    var countryB:String!

    let goalDelay = Timer()
    let gameTimer = Timer()
    var clockBackground:SKShapeNode?
    let clock = SKLabelNode(fontNamed: "Georgia")
    var gameTime: NSTimeInterval?
    var mode = Mode.threeMinute
    var playerOption = PlayerOption.three
    
    let pause = SKSpriteNode(texture: SKTexture(imageNamed: "Pause"), color: UIColor.clearColor(), size: SKTexture(imageNamed: "Pause").size())

    var turnA = true
    var scoreA = 0
    var scoreB = 0
    
    var scoreBackground:SKSpriteNode!
    var score = SKLabelNode(fontNamed: "Georgia")
    
    var timer: NSTimer?
    
    
    var moveTimer:Timer?
    override init(size:CGSize){
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
        scoreBackground = SKSpriteNode(color: UIColor.whiteColor()
            , size: CGSizeMake(800/568*midX!,200/320*midY!))
        scoreBackground.addChild(score)
        scoreBackground.zPosition = 4
        scoreBackground.alpha = 0.8
        score.fontSize = 50
        score.fontColor = UIColor.blackColor()
        scoreBackground.position = CGPoint(x: midX!, y: 1.3*midY!)
        score.zPosition = 2
        
        addChild(scoreBackground)
        
        background.position = CGPoint(x:midX!, y:midY!)
        background.size = self.frame.size
        background.zPosition=1
        addChild(background)
        scoreBackground.hidden = true
        // set rectangular border around screen
        let borderBody:SKPhysicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.linearDamping = 0
        borderBody.angularDamping = 0
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
        
        playerA1 = Player(teamA: true, country: countryA, sender: self)
        playerA2 = Player(teamA: true, country: countryA, sender: self)
        playerA3 = Player(teamA: true, country: countryA, sender: self)
        playerA4 = Player(teamA: true, country: countryA, sender: self)
        playerB1 = Player(teamA: false, country: countryB, sender: self)
        playerB2 = Player(teamA: false, country: countryB, sender: self)
        playerB3 = Player(teamA: false, country: countryB, sender: self)
        playerB4 = Player(teamA: false, country: countryB, sender: self)
        
        switch (playerOption){
        case PlayerOption.three:
            players = [playerA1, playerA2, playerA3, playerB1, playerB2, playerB3]
            break
        case PlayerOption.four:
            players = [playerA1, playerA2, playerA3, playerA4, playerB1, playerB2, playerB3, playerB4]
            break;
        }
        
        for node in players!{
            self.addChild(node)
        }
        
        // put ball in middle
        
        
        ball = Ball(scene: self)
        setPosition()
        self.addChild(ball)
        

        updateLighting()
        moveTimer = Timer()
        moveTimer?.restart()
        
        // set timer for threeMinute
        
        if (mode == Mode.threeMinute){
            gameTime = 180
            // set up clock
            clockBackground = SKShapeNode(rect: CGRectMake(-50/568*midX!,-25/320*midY!,100/568*midX!,50/320*midY!), cornerRadius: 10)
            clockBackground!.fillColor = UIColor.blackColor()
            clockBackground!.strokeColor = UIColor.whiteColor()
            clockBackground!.alpha = 0.7
            clock.text = gameTimer.secondsToString(gameTime!)
            clock.fontSize = 15
            clockBackground!.position = CGPoint(x: midX!, y: 7/4*midY!)
            clock.zPosition = 2
            clock.position = CGPointMake(0,-8/320*midY!)
            clock.fontColor = UIColor.whiteColor()
            gameTimer.start()
            clockBackground!.addChild(clock)
            clockBackground!.zPosition = 4
            self.addChild(clockBackground!)
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
        {
       /* Called when a touch begins */
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)

            
            if (node is Player){
                let touchedPlayer = (node as! Player)
                if touchedPlayer.mTeamA! == turnA {
                    selectedPlayer = touchedPlayer
                    playerSelected = true
                    startPosition = location
                    selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.4, duration: 0.00001))
                    
                }
            }
            else{
                
                for player in players!{
                    if player.mTeamA! == turnA && playerSelected == false{
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
    }
        
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
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
        if (!goalAccounted && 200/320 * midY! < ball.position.y && ball.position.y < 440/320 * midY!){
            if 0<ball.position.x && ball.position.x<50/568*midX!{
                
                self.reset(false)
            }
            else if 1086/568*midX! < ball.position.x {
                
                
                self.reset(true)
            }
        }
        
        if(moveTimer!.getElapsedTime() > 5){
            switchTurns()
        }
        if !gameEnded{
            showTime()
        }
        if (goalDelay.getElapsedTime()>2){
            goalDelay.reset()
            scoreBackground.hidden = true
            score.text = ""
            setDynamicStates(true)
            moveTimer?.restart()
            if mode == Mode.threeMinute{
                gameTimer.start()
            }
    
            setPosition()
            goalAccounted = false
            userInteractionEnabled = true
        }
        /* Called before each frame is rendered */
    }
    
    func reset(scoreGoal: Bool){
        // reset position of all players and ball
        goalAccounted = true
        if playerSelected{
            playerSelected = false
            selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.grayColor(), colorBlendFactor: -0.7, duration: 0.00001))
        }
        moveTimer?.restart()
        userInteractionEnabled = false
        if scoreGoal{
            scoreA+=1
        }
        else if !scoreGoal{
            scoreB+=1
        }
        setDynamicStates(false)
        scoreBackground.hidden = false

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
        goalDelay.start()
        
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
        gameTime = 180.1 - gameTimer.getElapsedTime()
        if (gameTime<=0){
            clock.text = "0:00"
            
            gameTimer.pause()
            moveTimer?.pause()
            endGame()
        }else{
            clock.text = gameTimer.secondsToString(gameTime!)
        }
    }
    
    func endGame(){
        gameEnded = true
        paused = true
        setDynamicStates(false)
        scoreBackground.hidden = false
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
        viewController.backToTitle()
    }
    
    func setPosition(){
        switch (playerOption){
        case PlayerOption.three:
            playerA1.position = CGPoint(x:midX!*0.3,y:midY!*1.5)
            playerA2.position = CGPoint(x:midX!*0.3,y:midY!*0.5)
            playerA3.position = CGPoint(x:midX!*0.7,y:midY!)
            playerB1.position = CGPoint(x:midX!*1.7,y:midY!*1.5)
            playerB2.position = CGPoint(x:midX!*1.7,y:midY!*0.5)
            playerB3.position = CGPoint(x:midX!*1.3,y:midY!)
            break
        case PlayerOption.four:
            playerA1.position = CGPoint(x:midX!*0.3,y:midY!*1.5)
            playerA2.position = CGPoint(x:midX!*0.3,y:midY!*0.5)
            playerA3.position = CGPoint(x:midX!*0.5,y:midY!*0.8)
            playerA4.position = CGPoint(x:midX!*0.5,y:midY!*1.2)
            playerB1.position = CGPoint(x:midX!*1.7,y:midY!*1.5)
            playerB2.position = CGPoint(x:midX!*1.7,y:midY!*0.5)
            playerB3.position = CGPoint(x:midX!*1.5,y:midY!*0.8)
            playerB4.position = CGPoint(x:midX!*1.5,y:midY!*1.2)
        }
        
        ball.position = CGPoint(x: midX!,y: midY!)
    }
    func distance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        let distX = point1.x-point2.x
        let distY = point1.y-point2.y
        return sqrt(distX*distX + distY*distY)
    }
    func restart(){
        scoreA = 0
        scoreB = 0
        if mode == Mode.threeMinute{
            gameTimer.restart()
        }
        setPosition()
        setDynamicStates(false)
        setDynamicStates(true)
        moveTimer?.restart()
        goalDelay.reset()
    }
}
