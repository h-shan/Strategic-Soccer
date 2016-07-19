//
//  GameScene.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright (c) 2016 HS. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

extension SKSpriteNode{
    func fadeIn(){
        self.runAction(SKAction.fadeAlphaTo(0.8, duration: 0.3))
        
    }
    func fadeOut(){
        self.runAction(SKAction.fadeAlphaTo(0, duration: 0.3))
    }
}
extension Bool{
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var selectedPlayer : Player?
    var startPosition : CGPoint?
    var playerSelected = false
    var goalA : Bool?
    var ball = Ball()
    
    var playerA1 = Player()
    var playerA2 = Player()
    var playerA3 = Player()
    var playerA4 = Player()
    var playerB1 = Player()
    var playerB2 = Player()
    var playerB3 = Player()
    var playerB4 = Player()
    var players: [Player]!
    var teamA: [Player]!
    var teamB: [Player]!
    var gameEnded = false
    var viewController: GameViewController!
    var goalAccounted = false
    
    var firstTurn = true
    var ownGoal = false
    var countryA:String!
    var countryB:String!
    
    var borderBody: SKPhysicsBody!

    var singlePlayer:Bool!
    var AIDifficulty: Int!
    var cAggro:Int?
    var cDef:Int?
    var computerCheckPoint:Double = 2
    
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
        
        scoreBackground = SKSpriteNode(color: UIColor.whiteColor()
            , size: CGSizeMake(800*scalerX,200*scalerY))
        scoreBackground.addChild(score)
        scoreBackground.zPosition = 4
        scoreBackground.alpha = 0.0
        score.fontSize = 50
        score.fontColor = UIColor.blackColor()
        scoreBackground.position = CGPoint(x: frame.midX, y: 1.3*frame.midY)
        score.zPosition = 2
        
        addChild(scoreBackground)
        addChild(scoreBoard)
        scoreBoard.position = CGPointMake(frame.midX,60*scalerY)
        scoreBoard.zPosition = 4
        
        background.position = CGPoint(x:frame.midX, y:frame.midY)
        background.size = self.frame.size
        background.zPosition=1.1
        addChild(background)
        // set rectangular border around screen
        borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.linearDamping = 0
        borderBody.angularDamping = 0
        self.physicsBody = borderBody
        self.physicsWorld.contactDelegate = self
        
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        // make soccer nets
        let netTexture = SKTexture(imageNamed: "SoccerNet")
        let netSize = CGSize(width: 80*scalerX, height: 240*scalerY)
        let leftSoccerNet = SKSpriteNode(texture: netTexture,color: UIColor.clearColor(), size: netSize)
        let rightSoccerNet = SKSpriteNode(texture: netTexture,color: UIColor.clearColor(), size: netSize)
        rightSoccerNet.position = CGPoint(x: 1096*scalerX, y: frame.midY)
        leftSoccerNet.position = CGPoint(x:40*scalerX, y: frame.midY)
        rightSoccerNet.zRotation = CGFloat(M_PI)
        rightSoccerNet.zPosition = 3
        leftSoccerNet.zPosition = 3
        addChild(leftSoccerNet)
        addChild(rightSoccerNet)
        
        // set goal posts in place
        let actualSize = CGSizeMake(80*scalerX, 5*scalerX)
        goalPostA1 = GoalPost(sender: self, actualSize: actualSize)
        goalPostA2 = GoalPost(sender: self, actualSize: actualSize)
        goalPostB1 = GoalPost(sender: self, actualSize: actualSize)
        goalPostB2 = GoalPost(sender: self, actualSize: actualSize)
        goalPostA1.position = CGPoint(x: 40*scalerX, y: 440*scalerY)
        goalPostA2.position = CGPoint(x: 40*scalerX, y: 200*scalerY)
        goalPostB1.position = CGPoint(x: 1096*scalerX, y: 440*scalerY)
        goalPostB2.position = CGPoint(x: 1096*scalerX, y: 200*scalerY)
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
            teamA = [playerA1,playerA2,playerA3]
            teamB = [playerB1, playerB2, playerB3]
            break
        case PlayerOption.four:
            players = [playerA1, playerA2, playerA3, playerA4, playerB1, playerB2, playerB3, playerB4]
            teamA = [playerA1, playerA2, playerA3]
            teamB = [playerB1, playerB2, playerB3]
            break;
        }
        
        for node in players{
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
            clockBackground = SKShapeNode(rect: CGRectMake(-50*scalerX,-25*scalerY,100*scalerX,50*scalerY), cornerRadius: 10)
            clockBackground!.fillColor = UIColor.blackColor()
            clockBackground!.strokeColor = UIColor.whiteColor()
            clockBackground!.alpha = 0.7
            clock.text = gameTimer.secondsToString(baseTime!)
            clock.fontSize = 15
            clockBackground!.position = CGPoint(x: frame.midX, y: 7/4*frame.midY)
            clock.zPosition = 2
            clock.position = CGPointMake(0,-8*scalerY)
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
                    for player in players{
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
        for player in players{
            player.setLighting(player.mTeamA != turnA)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (!goalAccounted && 200*scalerY < ball.position.y && ball.position.y < 440*scalerY){
            if ball.position.x<50*scalerX{
                
                self.reset(false)
            }
            else if 1086*scalerX < ball.position.x {
                
                
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
            scoreBackground.fadeOut()
            score.text = ""
            setDynamicStates(true)
            moveTimer?.restart()
            if mode.getType() == .timed{
                gameTimer.start()
            }
            for child in children{
                if child.name == "blue"{
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
        scoreBackground.fadeIn()

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
        for player in self.players{
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
        setDynamicStates(false)
        scoreBackground.fadeIn()
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
            playerA1.position = CGPoint(x:frame.midX*0.3,y:frame.midY*1.5)
            playerA2.position = CGPoint(x:frame.midX*0.3,y:frame.midY*0.5)
            playerA3.position = CGPoint(x:frame.midX*0.7,y:frame.midY)
            playerB1.position = CGPoint(x:frame.midX*1.7,y:frame.midY*1.5)
            playerB2.position = CGPoint(x:frame.midX*1.7,y:frame.midY*0.5)
            playerB3.position = CGPoint(x:frame.midX*1.3,y:frame.midY)
            break
        case PlayerOption.four:
            playerA1.position = CGPoint(x:frame.midX*0.3,y:frame.midY*1.5)
            playerA2.position = CGPoint(x:frame.midX*0.3,y:frame.midY*0.5)
            playerA3.position = CGPoint(x:frame.midX*0.5,y:frame.midY*0.8)
            playerA4.position = CGPoint(x:frame.midX*0.5,y:frame.midY*1.2)
            playerB1.position = CGPoint(x:frame.midX*1.7,y:frame.midY*1.5)
            playerB2.position = CGPoint(x:frame.midX*1.7,y:frame.midY*0.5)
            playerB3.position = CGPoint(x:frame.midX*1.5,y:frame.midY*0.8)
            playerB4.position = CGPoint(x:frame.midX*1.5,y:frame.midY*1.2)
        }
        
        ball.position = CGPoint(x: frame.midX,y: frame.midY)
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
        computerCheckPoint = 2
        setPosition()
        setDynamicStates(false)
        setDynamicStates(true)
        moveTimer?.restart()
        goalDelay.reset()
        scoreBackground.fadeOut()
        goalAccounted = false
        if !turnA{
            switchTurns()
        }
        scoreBoard.label.text = "0    0"
    }
    func computerMove(cAggro: Int, cDef: Int){
        if firstTurn{
            for player in teamA{
                if abs(player.physicsBody!.velocity.dx) > 30 || abs(player.physicsBody!.velocity.dy) > 30{
                    firstTurn = false
                    break
                }
            }
        }
        let checkInterval = 0.2
        let timeLimit = 2.5
        
        if AIDifficulty >= 3 {
            if (moveTimer?.getElapsedTime())!>checkInterval*computerCheckPoint && !firstTurn{
                if straightShot(){
                    switchTurns()
                    computerCheckPoint = 2
                    return
                }
                if AIDifficulty >= 4{
                    if saveGoal(){
                        switchTurns()
                        computerCheckPoint = 2
                        return
                    }
                }
                computerCheckPoint += 1
            }
        }
        if moveTimer?.getElapsedTime()>timeLimit{
            if firstTurn{
                firstMove()
                firstTurn = false
            }
            else{
                switch(AIDifficulty){
                case 1: hitBallBasic(); break
                case 2: if !hitBallAdvanced() {hitBallBasic()}; break
                case 3: if !hitBallAdvanced() {hitBallBasic()}; break
                case 4: if !hitBallAdvanced() {hitBallBasic()}; break
                case 5: improvePosition(); break
                default: break
                }
            }
            computerCheckPoint = 2
            switchTurns()
        }
        
    }
    func firstMove(){
        //if playerOption == PlayerOption.three{
            let random = arc4random_uniform(3)
            switch (random){
            case 0:
                playerB1.physicsBody!.velocity = CGVectorMake(playerA1.position.x-playerB1.position.x,playerA3.position.y - playerB1.position.y)
                addMarker(UIColor.orangeColor(), point: playerB1.position)

                break
            case 1:
                playerB2.physicsBody!.velocity = CGVectorMake(playerA1.position.x-playerB2.position.x,playerA3.position.y - playerB2.position.y)
                addMarker(UIColor.orangeColor(), point: playerB2.position)
                break
            case 2:
                playerB3.physicsBody!.velocity = CGVectorMake(playerA1.position.x-playerB3.position.x,playerA3.position.y - playerB3.position.y)
                addMarker(UIColor.orangeColor(), point: playerB3.position)

                break
            default:
                break
            }
        //}
        
    }
    func straightShot() -> Bool{
        var bestShot:(Player, CGVector, Int)?
        PLAYERLOOP: for player in teamB{
            var multiplier:CGFloat = 0.3
            var minBar = 3
            while (multiplier <= 0.6){
                let predictedBallPosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*multiplier, ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                if !frame.contains(predictedBallPosition){
                    return false
                }
                if detectBarriers(ball.position, velocity: ball.physicsBody!.velocity, xLimit: predictedBallPosition.x, fromRight: predictedBallPosition.x < ball.position.x)>0{
                    return false
                }
                let toPointVelocity = CGVectorMake((predictedBallPosition.x-player.position.x),(predictedBallPosition.y - player.position.y))
                let angle = atan(toPointVelocity.dy/toPointVelocity.dx)
                let buffer = player.playerSize.width*5/12
                let predictedPlayerPosition = CGPointMake(predictedBallPosition.x + cos(angle)*buffer,predictedBallPosition.y + sin(angle)*buffer)
                let straightShotVelocity = CGVectorMake((predictedPlayerPosition.x-player.position.x)/multiplier, (predictedPlayerPosition.y-player.position.y)/multiplier)
                if straightShotVelocity.dx > 0 {
                    continue PLAYERLOOP
                }
                
                let xDistance = player.position.x - 50*scalerX
                if xDistance < 0 {
                    continue PLAYERLOOP
                }
                if ball.position.x < 50*scalerX{
                    multiplier+=0.1
                    continue
                }
                
                if detectGoal(player.position, velocity: straightShotVelocity, xLimit: goalLineA, fromRight: true){
                    // detectObstacles
                    let numBar = detectBarriers(player.position, velocity: straightShotVelocity, xLimit: goalLineB, fromRight: true)
                    if numBar == 0{
                        player.physicsBody!.velocity = dampVelocity(straightShotVelocity)
                        return true
                    }
                    if numBar < minBar{
                        bestShot = (player, straightShotVelocity, numBar)
                        minBar = numBar
                    }
                }
                multiplier += 0.1
            }
        }
        if var shot = bestShot{
            shot.1 = dampVelocity(shot.1)
            shot.0.physicsBody!.velocity = shot.1
            addMarker(UIColor.blueColor(), point: shot.0.position)
            return true
        }
        return false
    }
    func detectBarriers(startingPoint: CGPoint, velocity: CGVector, xLimit: CGFloat, fromRight: Bool) -> Int{
        var xPosition = (startingPoint.x)
        var yPosition = (startingPoint.y)
        var detectedBarriers = [SKPhysicsBody]()
        var objectAtPoint: SKPhysicsBody?
        detectedBarriers.append(ball.physicsBody!)
        if fromRight{
            while (xPosition > xLimit && xPosition < frame.maxX && yPosition > 0 && yPosition < frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
                objectAtPoint = physicsWorld.bodyAtPoint(CGPointMake(xPosition, yPosition))
                if objectAtPoint != nil && !detectedBarriers.contains(objectAtPoint!){
                    detectedBarriers.append(objectAtPoint!)
                    if objectAtPoint!.node is GoalPost{
                        return 100
                    }
                }
            }
        }
        else{
            while (xPosition < xLimit && xPosition < frame.maxX && yPosition > 0 && yPosition < frame.maxY){
                xPosition += 2
                yPosition += 2*velocity.dy/velocity.dx
                objectAtPoint = physicsWorld.bodyAtPoint(CGPointMake(xPosition, yPosition))
                if objectAtPoint != nil && !detectedBarriers.contains(objectAtPoint!){
                    detectedBarriers.append(objectAtPoint!)
                    if objectAtPoint!.node is GoalPost{
                        return 100
                    }
                }
            }
        }
        return detectedBarriers.count-1
    }
    func detectGoal(start: CGPoint, velocity: CGVector, xLimit: CGFloat, fromRight: Bool) -> Bool{
        if (velocity.dx >= 0 && fromRight) || (velocity.dx <= 0 && !fromRight){
            return false
        }
        var xPosition = start.x
        var yPosition = start.y
        if fromRight{
            while (xPosition>xLimit && xPosition < frame.maxX && yPosition > 0 && yPosition < frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
            }
        }
        else{
            while (xPosition<xLimit && xPosition > 0 && yPosition > 0 && yPosition < frame.maxY){
                xPosition += 2
                yPosition += 2*velocity.dy/velocity.dx
            }
        }
        if goalPostA1.position.y>yPosition && yPosition>goalPostA2.position.y{
            return true
        }
        return false
    
    }
    func saveGoal() -> Bool{
        if detectGoal(ball.position, velocity: ball.physicsBody!.velocity, xLimit: goalLineB, fromRight: false){
            var shots = [(Player, CGVector, Int)]()
            
            var multiplier:CGFloat = 0.3
            for player in teamB{
                var predictedBallPosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*multiplier, ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                while !frame.contains(predictedBallPosition) && multiplier > 0{
                    multiplier -= 0.1
                    predictedBallPosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*multiplier, ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                }
                let toPointVelocity = CGVectorMake((predictedBallPosition.x-player.position.x),(predictedBallPosition.y - player.position.y))
                let angle = atan(toPointVelocity.dy/toPointVelocity.dx)
                //let buffer = player.playerSize.width*5/12
                let buffer:CGFloat = 0
                let predictedPlayerPosition = CGPointMake(predictedBallPosition.x + cos(angle)*buffer,predictedBallPosition.y + sin(angle)*buffer)
                let blockVelocity = CGVectorMake((predictedPlayerPosition.x-player.position.x)/multiplier, (predictedPlayerPosition.y-player.position.y)/multiplier)
                let numBar = detectBarriers(player.position, velocity: blockVelocity, xLimit: goalLineB, fromRight: player.position.x > ball.position.x)
                shots.append((player,blockVelocity, numBar))
                
            }
            var minBar = shots[0].2
            for shot in shots{
                if shot.2 < minBar{
                    minBar = shot.2
                }
            }
            if minBar > 10 {
                return false
            }
            var bestShot: (Player, CGVector, Int)?
            var bestAngle: CGFloat = 0
            for shot in shots{
                if shot.2 == minBar{
                    if bestShot != nil{
                        if shot.1.dx/abs(shot.1.dy) < bestAngle{
                            bestShot = shot
                            bestAngle = shot.1.dx/abs(shot.1.dy)
                        }
                    }
                    else{
                        bestShot = shot
                        bestAngle = shot.1.dx/abs(shot.1.dy)
                    }
                }
            }
            let finalVelocity = dampVelocity(bestShot!.1)
            bestShot!.0.physicsBody!.velocity = finalVelocity
            addMarker(UIColor.yellowColor(), point: bestShot!.0.position)
            return true
        }
        return false
    }
    func dampVelocity(velocity: CGVector) -> CGVector{
        var dampedVelocity = velocity
        let maxX:CGFloat = 500
        //let minX:CGFloat = 100
        let maxY:CGFloat = 300
        while abs(dampedVelocity.dx)>maxX || /*abs(velocity.dx)<minX ||*/ abs(dampedVelocity.dy) > maxY{
//            if velocity.dx < minX && velocity.dx > 0{
//                dampedVelocity.dy = velocity.dy*minX/velocity.dx
//                dampedVelocity.dx = minX
//            }
//            if velocity.dx > -minX && velocity.dx < 0{
//                dampedVelocity.dy = -velocity.dy*minX/velocity.dx
//                dampedVelocity.dx = -minX
//            }
            
            if dampedVelocity.dx > maxX{
                dampedVelocity.dy = velocity.dy * maxX/velocity.dx
                dampedVelocity.dx = maxX
            }
            if dampedVelocity.dy > maxY{
                dampedVelocity.dx = velocity.dx * maxY/velocity.dy
                dampedVelocity.dy = maxY
            }
            if dampedVelocity.dx < -maxX{
                dampedVelocity.dy = velocity.dy * -maxX/velocity.dx
                dampedVelocity.dx = -maxX
            }
            if dampedVelocity.dy < -maxY{
                dampedVelocity.dx = velocity.dx * -maxY/velocity.dy
                dampedVelocity.dy = -maxY
            }
        }
        return dampedVelocity
    }
    func improvePosition(){
        if outOfCorner(){
            return
        }
        if Bool.random(){
            if hitBallAdvanced(){
                return
            }
        }
        if getBehindBall(){
            return
        }
        deflectPlayer()
    }
    func outOfCorner() -> Bool{
        for player in teamB{
            //check corners
            if player.position.x > goalPostB1.position.x-goalPostB1.size.width || player.position.x < goalPostA1.position.x + goalPostA1.size.width{
                // player in opponent goal
                if player.position.x < frame.midX{
                    if player.position.y < goalPostA1.position.y && player.position.y > goalPostA2.position.y{
                        if Bool.random(){
                            player.physicsBody!.velocity = CGVectorMake((frame.midX - player.position.x)/3, (goalPostA1.position.y-player.position.y)/3)
                        }else{
                            player.physicsBody!.velocity = CGVectorMake((frame.midX - player.position.x)/3, (goalPostA2.position.y - player.position.y)/3)
                        }
                        addMarker(UIColor.blackColor(), point: player.position)
                        return true
                    }
                }
                // player in top corners
                if player.position.y > goalPostA1.position.y{
                    if abs(player.physicsBody!.velocity.dx) < 100{
                        player.physicsBody!.velocity = CGVectorMake((frame.midX - player.position.x)/3, (goalPostA1.position.y-player.position.y)/3)
                        addMarker(UIColor.blackColor(), point: player.position)
                        return true
                    }
                    
                }
                //player in bottom corners
                if player.position.y < goalPostA2.position.y{
                    if abs(player.physicsBody!.velocity.dx) < 100{
                        player.physicsBody!.velocity = CGVectorMake((frame.midX - player.position.x)/3, (goalPostA2.position.y - player.position.y)/3)
                        addMarker(UIColor.blackColor(), point: player.position)
                        return true
                    }
                }
            }
        }
        return false
        
    }
    func hitBallBasic(){
        let random: UInt32
        switch(playerOption){
        case .three: random = arc4random_uniform(3); break
        case .four: random = arc4random_uniform(4); break
        }
        let time:CGFloat = 0.5
        let selectedPlayer = teamB[Int(random)]
        let ballFuturePosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*time,ball.position.y + ball.physicsBody!.velocity.dy*time)
        selectedPlayer.physicsBody!.velocity = dampVelocity(CGVectorMake((ballFuturePosition.x-selectedPlayer.position.x)/time, (ballFuturePosition.y-selectedPlayer.position.y)/time))
        addMarker(UIColor.magentaColor(), point: selectedPlayer.position)
    }
    func hitBallAdvanced() -> Bool{
        let ballMultiplier:CGFloat = 0.5
        var ballFuturePosition = CGPointMake(ball.position.x + ball.physicsBody!.velocity.dx*ballMultiplier, ball.position.y + ball.physicsBody!.velocity.dy*ballMultiplier)
        while !frame.contains(ballFuturePosition){
            let firstVelocity = CGVectorMake(ballFuturePosition.x - ball.position.x, ballFuturePosition.y - ball.position.y)
            if ballFuturePosition.x < 0 || ballFuturePosition.x > frame.maxX{
                if detectBarriers(ball.position,velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: firstVelocity.dx < 0) == 100{
                    return false
                }
                let secondVelocity = CGVectorMake(-firstVelocity.dx, firstVelocity.dy)
                if ballFuturePosition.x < 0{
                    ballFuturePosition.x = -ballFuturePosition.x
                }
                else if ballFuturePosition.x > frame.maxX{
                    ballFuturePosition.x = 2*frame.maxX-ballFuturePosition.x
                }
                if detectBarriers(ball.position,velocity: secondVelocity, xLimit: ballFuturePosition.x, fromRight: secondVelocity.dx < 0) == 100{
                    return false
                }

            }
            if ballFuturePosition.y < 0 || ballFuturePosition.y>frame.maxY{
                if detectBarriers(ball.position, velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: firstVelocity.dx < 0) == 100{
                    return false
                }
                let secondVelocity = CGVectorMake(firstVelocity.dx, -firstVelocity.dy)
                if detectBarriers(ball.position, velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: secondVelocity.dx < 0) == 100{
                    return false
                }
                if ballFuturePosition.y < 0{
                    ballFuturePosition.y = -ballFuturePosition.y
                }
                else if ballFuturePosition.y > frame.maxY{
                    ballFuturePosition.y = 2*frame.maxY-ballFuturePosition.y
                }
            }
        }
        var shots = [(Player, CGVector, Int)]()
        for player in teamB{
            let playerVelocity = CGVectorMake(2*ballMultiplier*(ballFuturePosition.x-player.position.x), 2*ballMultiplier*(ballFuturePosition.y - player.position.y))
            let numBar = detectBarriers(player.position,velocity: playerVelocity, xLimit: ball.position.x, fromRight: playerVelocity.dx < 0)
            if playerVelocity.dx < 0{
                shots.append((player,playerVelocity,numBar))
            }
        }
        var minBar = 10
        var bestShot: (Player, CGVector, Int)?
        for shot in shots{
            if shot.2 < minBar{
                minBar = shot.2
                bestShot = shot
                bestShot!.1 = dampVelocity(bestShot!.1)
            }
        }
        if let finalShot = bestShot{
            let finalVelocity = dampVelocity(finalShot.1)
            finalShot.0.physicsBody!.velocity = finalVelocity
            addMarker(UIColor.redColor(), point: finalShot.0.position)
            return true
        }
        return false
        
    }
    func getBehindBall() -> Bool{
        if ball.position.x < frame.midX{
            return false
        }
        let deflater:CGFloat = 1/3
        for player in teamB{
            if player.position.x < frame.maxX/3{
                player.physicsBody!.velocity = dampVelocity(CGVectorMake((goalLineB - player.position.x) * deflater, (frame.midY-player.position.y) * deflater))
                addMarker(UIColor.purpleColor(), point: player.position)
                return true
            }
        }
        return false
    }
    func deflectPlayer(){
        var closestDistance:CGFloat = 1000
        var closestOpponent = playerA1
        for player in teamA{
            if distance(player.position,point2:ball.position) < closestDistance{
                closestDistance = distance(player.position, point2: ball.position)
                closestOpponent = player
            }
        }
        var shots = [(Player,CGVector, Int)]()
        
        for player in teamB{
            let shotVelocity = CGVectorMake(closestOpponent.position.x-player.position.x,closestOpponent.position.y-player.position.y)
            let numBar = detectBarriers(player.position,velocity: shotVelocity, xLimit: closestOpponent.position.x, fromRight: shotVelocity.dx < 0)
            shots.append(player,shotVelocity, numBar)
        }
        var minBar = 10
        var bestShot: (Player, CGVector, Int)?
        for shot in shots{
            if shot.2 < minBar{
                minBar = shot.2
                bestShot = shot
            }
        }
        bestShot!.1 = dampVelocity(bestShot!.1)
        bestShot!.0.physicsBody!.velocity = bestShot!.1
        addMarker(UIColor.brownColor(),point: bestShot!.0.position)
    }
    func addMarker(color: UIColor, point: CGPoint){
        let blue = SKSpriteNode(imageNamed: "PlayerA")
        blue.runAction(SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 0.0001))
        blue.size = CGSizeMake(10,10)
        blue.position = point
        blue.zPosition = 2
        blue.name = "blue"
        addChild(blue)
    }
}

