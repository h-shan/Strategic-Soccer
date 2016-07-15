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
    
    var firstTurn = true
    var ownGoal = false
    var countryA:String!
    var countryB:String!
    
    var borderBody: SKPhysicsBody!

    var singlePlayer:Bool!
    var cAggro:Int?
    var cDef:Int?
    
    let goalDelay = Timer()
    let gameTimer = Timer()
    var clockBackground:SKShapeNode?
    let clock = SKLabelNode(fontNamed: "Georgia")
    
    var winPoints: Int?
    var baseTime: NSTimeInterval?
    var gameTime: NSTimeInterval?
    
    
    var mode = Mode.threeMinute
    var playerOption = PlayerOption.three
    var goalPostA1: GoalPost!
    var goalPostA2: GoalPost!
    var goalPostB1: GoalPost!
    var goalPostB2: GoalPost!
    
    var scoreBoard: ScoreBoard!

    var turnA = true
    var scoreA = 0
    var scoreB = 0
    
    var scoreBackground:SKSpriteNode!
    var score = SKLabelNode(fontNamed: "Georgia")
    
    var timer: NSTimer?
    
    
    var moveTimer:Timer?
    override init(size:CGSize){
        super.init(size: size)
        scoreBoard = ScoreBoard(sender: self)
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func didBeginContact(contact: SKPhysicsContact){
        let ballVelocity = ball.physicsBody!.velocity
        if contact.bodyA == borderBody && contact.bodyB == ball.physicsBody!{
            if 0 <= ballVelocity.dx && ballVelocity.dx < 20{
                ball.physicsBody!.velocity = CGVectorMake(20,ball.physicsBody!.velocity.dy)
            }
            if -20 < ballVelocity.dx && ballVelocity.dx < 0 {
                ball.physicsBody!.velocity = CGVectorMake(-20, ball.physicsBody!.velocity.dy)
            }
            if 0 <= ballVelocity.dy && ballVelocity.dy < 20{
                ball.physicsBody!.velocity = CGVectorMake(ball.physicsBody!.velocity.dx,20)
            }
            if -20 < ballVelocity.dy && ballVelocity.dy < 0{
                ball.physicsBody!.velocity = CGVectorMake(ball.physicsBody!.velocity.dx,-20)
            }
        }
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
        addChild(scoreBoard)
        scoreBoard.position = CGPointMake(midX!,60/568*midX!)
        scoreBoard.zPosition = 4
        
        background.position = CGPoint(x:midX!, y:midY!)
        background.size = self.frame.size
        background.zPosition=1.1
        addChild(background)
        scoreBackground.hidden = true
        // set rectangular border around screen
        borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
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
        let actualSize = CGSizeMake(80/568*self.frame.midX, 5/568*self.frame.midX)
        goalPostA1 = GoalPost(sender: self, actualSize: actualSize)
        goalPostA2 = GoalPost(sender: self, actualSize: actualSize)
        goalPostB1 = GoalPost(sender: self, actualSize: actualSize)
        goalPostB2 = GoalPost(sender: self, actualSize: actualSize)
        goalPostA1.position = CGPoint(x: 40/568*midX!, y: midY!*440/320)
        goalPostA2.position = CGPoint(x: 40/568*midX!, y: midY!*200/320)
        goalPostB1.position = CGPoint(x: 1096/568*midX!, y: midY!*440/320)
        goalPostB2.position = CGPoint(x: 1096/568*midX!, y: midY!*200/320)
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
            node.zPosition = 2
            self.addChild(node)
        }
        
        // put ball in middle
        
        
        ball = Ball(scene: self)
        ball.zPosition = 2
        setPosition()
        self.addChild(ball)
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask


        updateLighting()
        moveTimer = Timer()
        moveTimer?.restart()
        
        if (mode.getType() == .points){
            switch (mode){
            case .threePoint:
                winPoints = 3
            case .fivePoint:
                winPoints = 5
            case .tenPoint:
                winPoints = 10
            case .twentyPoint:
                winPoints = 20
            default:
                break
            }

        }
        
        // set timer for timed
        
        if (mode.getType() == .timed){
            switch(mode){
            case .oneMinute:
                baseTime = 60.5
                break
            case .threeMinute:
                baseTime = 180.5
                break
            case .fiveMinute:
                baseTime = 300.5
                break
            case .tenMinute:
                baseTime = 600.5
                break
            default:
                break
            }
            // set up clock
            clockBackground = SKShapeNode(rect: CGRectMake(-50/568*midX!,-25/320*midY!,100/568*midX!,50/320*midY!), cornerRadius: 10)
            clockBackground!.fillColor = UIColor.blackColor()
            clockBackground!.strokeColor = UIColor.whiteColor()
            clockBackground!.alpha = 0.7
            clock.text = gameTimer.secondsToString(baseTime!)
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

            if !singlePlayer || (singlePlayer && turnA){
                if (node is Player){
                    let touchedPlayer = (node as! Player)
                    if touchedPlayer.mTeamA == turnA {
                        selectedPlayer = touchedPlayer
                        playerSelected = true
                        startPosition = location
                        selectedPlayer!.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.4, duration: 0.00001))
                        
                    }
                }
                else{
                    for player in players!{
                        if player.mTeamA == turnA && playerSelected == false{
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
        
        if singlePlayer && !turnA{
            computerMove(cAggro!, cDef: cDef!)
        }
        
        if(moveTimer!.getElapsedTime() > 5){
            switchTurns()
        }
        if mode.getType() == .timed && !gameEnded{
            showTime()
        }
        if (goalDelay.getElapsedTime()>2){
            goalDelay.reset()
            scoreBackground.hidden = true
            score.text = ""
            setDynamicStates(true)
            moveTimer?.restart()
            if mode.getType() == .timed{
                gameTimer.start()
            }
            for child in children{
                if child.name == "yellow" || child.name == "blue"{
                    child.removeFromParent()
                }
            }
    
            setPosition()
            goalAccounted = false
            userInteractionEnabled = true
            if ownGoal{
                switchTurns()
                ownGoal = false
            }
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
        if turnA == scoreGoal{
            ownGoal = true
        }
        moveTimer?.reset()
        userInteractionEnabled = false
        if scoreGoal{
            scoreA+=1
        }
        else if !scoreGoal{
            scoreB+=1
        }
        scoreBoard.label.text = String.localizedStringWithFormat("%d    %d", scoreA, scoreB)
        setDynamicStates(false)
        scoreBackground.hidden = false

        if mode.getType() == .points{
            if scoreA == winPoints! || scoreB == winPoints! {
                endGame()
            }
            else{
                score.text = String.localizedStringWithFormat("%d - %d", scoreA, scoreB)
            }
        }
            
        else{
            score.text = String.localizedStringWithFormat("%d - %d", scoreA, scoreB)
        }

        if mode.getType() == .timed{
            gameTimer.pause()
        }
        if singlePlayer == true{
            firstTurn = true
        }
        goalDelay.start()
        
    }
    
    
    func setDynamicStates(isDynamic: Bool){
        for player in self.players!{
            player.physicsBody!.dynamic = isDynamic
        }
        ball.physicsBody!.dynamic = isDynamic
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
        gameTime = baseTime! - gameTimer.getElapsedTime()
        if (gameTime<=0){
            clock.text = "0:00"
            gameTimer.pause()
            moveTimer?.pause()
            endGame()
        }else{
            if clock.text != gameTimer.secondsToString(gameTime!){
                clock.text = gameTimer.secondsToString(gameTime!)
            }
        }
        if gameTime <= 30{
            clock.color = UIColor.redColor()
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
        if mode.getType() == .timed{
            gameTimer.restart()
        }
        setPosition()
        setDynamicStates(false)
        setDynamicStates(true)
        moveTimer?.restart()
        goalDelay.reset()
        scoreBackground.hidden = true
        goalAccounted = false
        if !turnA{
            switchTurns()
        }
        scoreBoard.label.text = "0    0"
    }
    func computerMove(cAggro: Int, cDef: Int){
        if (moveTimer?.getElapsedTime())!%0.2<0.1 && (moveTimer?.getElapsedTime())! > 0.4{
            for player in players!{
                if !player.mTeamA{
                    if detectStraightShot(player){
                        switchTurns()
                        return
                    }
                }
            }
        }
        if moveTimer?.getElapsedTime()>2.5{

            if firstTurn == true{
                firstTurn = false
                firstMove()
            }
            else{
            let random = CGFloat(arc4random_uniform(30))
            let ballMultiplier:CGFloat = 0.5
            let chosePlayer:UInt32
            if playerOption == PlayerOption.three{
                chosePlayer = arc4random_uniform(3)+3
            }
            else{
                chosePlayer = arc4random_uniform(4) + 4
            }
            var closestPlayer:Player = playerB1
            closestPlayer = players![Int(chosePlayer)]
            
            var ballFuturePosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*ballMultiplier, ball.position.y + ball.physicsBody!.velocity.dy*ballMultiplier)
                if ballFuturePosition.x < 0 {
                    ballFuturePosition.x = -ballFuturePosition.x
                }
                else if ballFuturePosition.x > frame.maxX{
                    ballFuturePosition.x = 2*frame.maxX-ballFuturePosition.x
                }
                if ballFuturePosition.y < 0 {
                    ballFuturePosition.y = -ballFuturePosition.y
                }
                else if ballFuturePosition.y > frame.maxY{
                    ballFuturePosition.y = 2*frame.maxY-ballFuturePosition.y
                }
                
            let playerVelocity = CGVectorMake(2*ballMultiplier*(ballFuturePosition.x-closestPlayer.position.x)+random, 2*ballMultiplier*(ballFuturePosition.y - closestPlayer.position.y)+random)
            closestPlayer.physicsBody!.velocity = playerVelocity
            }
        
            switchTurns()
        }
    }
    func firstMove(){
        //if playerOption == PlayerOption.three{
            let random = arc4random_uniform(3)
            switch (random){
            case 0:
                playerB1.physicsBody!.velocity = CGVectorMake(playerA1.position.x-playerB1.position.x,playerA3.position.y - playerB1.position.y)
                break
            case 1:
                playerB2.physicsBody!.velocity = CGVectorMake(playerA1.position.x-playerB2.position.x,playerA3.position.y - playerB2.position.y)
                break
            case 2:
                playerB3.physicsBody!.velocity = CGVectorMake(playerA1.position.x-playerB3.position.x,playerA3.position.y - playerB3.position.y)
                break
            default:
                break
            }
        //}
        
    }
    func detectStraightShot(player: Player) -> Bool{
        var multiplier:CGFloat = 0.3
        var buffed = false
        LOOP: while (multiplier <= 0.6){
            let predictedBallPosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*multiplier, ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
            let toPointVelocity = CGVectorMake((predictedBallPosition.x-player.position.x),(predictedBallPosition.y - player.position.y))
            let angle = atan(toPointVelocity.dy/toPointVelocity.dx)
            let buffer = CGFloat(ball.radius) + player.playerSize.width*5/12
            let predictedPlayerPosition = CGPointMake(predictedBallPosition.x + cos(angle)*buffer,predictedBallPosition.y + sin(angle)*buffer)
            var straightShotVelocity = CGVectorMake((predictedPlayerPosition.x-player.position.x)/multiplier, (predictedPlayerPosition.y-player.position.y)/multiplier)
            if straightShotVelocity.dx > 0 {
                return false
            }
            if abs(ball.physicsBody!.velocity.dy) < 100 && straightShotVelocity.dx > -200{
                straightShotVelocity.dy *= -200/straightShotVelocity.dx
                straightShotVelocity.dx = -200
                buffed = true
            }

            
            let xDistance = player.position.x - 50/568*midX!
            if xDistance < 0 {
                return false
            }
            if ball.position.x < 50/568*midX!{
                multiplier+=0.1
                continue LOOP
            }
            let finalPositionY = -straightShotVelocity.dy*(xDistance/straightShotVelocity.dx) + player.position.y
            
            var xPosition:CGFloat = player.position.x
            var yPosition:CGFloat = player.position.y
            if goalPostA1.position.y > finalPositionY && finalPositionY > goalPostA2.position.y{
                // detectObstacles
                
                var objectAtPoint: SKPhysicsBody?
                while xPosition > 50/568*midX!{
                    xPosition -= 2
                    yPosition -= straightShotVelocity.dy/straightShotVelocity.dx*2
                    objectAtPoint = physicsWorld.bodyAtPoint(CGPointMake(xPosition, yPosition))
                    if objectAtPoint != nil && objectAtPoint != player.physicsBody! && objectAtPoint != ball.physicsBody!{
                        break
                    }
                }
                if objectAtPoint == nil{
                    if straightShotVelocity.dx < -500{
                        straightShotVelocity.dy *= -500/straightShotVelocity.dx
                        straightShotVelocity.dx = -500
                    }

                    player.physicsBody!.velocity = straightShotVelocity
                    let blue = SKSpriteNode(imageNamed: "PlayerA")
                    blue.size = CGSizeMake(10,10)
                    if buffed{
                        blue.size = CGSizeMake(20,20)
                    }
                    print(straightShotVelocity.dx)
                    blue.position = player.position
                    blue.zPosition = 2
                    blue.name = "blue"
                    addChild(blue)
                    let yellow = SKSpriteNode(imageNamed: "PlayerB")
                    yellow.name = "yellow"
                    yellow.size = CGSizeMake(10,10)
                    yellow.position = predictedPlayerPosition
                    yellow.zPosition = 2
                    addChild(yellow)
                    return true
                }
            }
            multiplier += 0.1
        }
        return false
    }
    func detectBarriers(velocity: CGVector, xLimit: CGFloat) -> Int{
        let startingPoint = ball.position
        var xPosition = (startingPoint.x)
        var yPosition = (startingPoint.y)
        var detectedBarriers = [SKPhysicsBody]()
        var objectAtPoint: SKPhysicsBody?
        detectedBarriers.append(ball.physicsBody!)
        while (xPosition > xLimit && xPosition < frame.maxX && yPosition > 0 && yPosition < frame.maxY){
            xPosition -= 2
            yPosition -= 2*velocity.dy/velocity.dx
            objectAtPoint = physicsWorld.bodyAtPoint(CGPointMake(xPosition, yPosition))
            if objectAtPoint != nil && !detectedBarriers.contains(objectAtPoint!){
                detectedBarriers.append(objectAtPoint!)
            }
        }
        return detectedBarriers.count-1
    }
}
