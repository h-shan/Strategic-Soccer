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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let difficulty1Multiplier = 1
let difficulty2Multiplier = 1.5
let difficulty3Multiplier = 2
let difficulty4Multiplier = 3
let difficulty5Multiplier = 4
extension SKNode{
    func fadeIn(){
        self.run(SKAction.fadeAlpha(to: 0.8, duration: 0.3))
        
    }
    func fadeOut(){
        self.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
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
    var timeLimit:Double = 2.5

    var gamePositions = [([(SKSpriteNode,CGPoint,CGVector)],Double)]()

    var nameNode = [String:SKSpriteNode]()
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
    var loaded = true
    
    var isSynced = false
    var firstTurn = true
    var ownGoal = false
    var countryA:String!
    var countryB:String!
    
    var borderBodyNode: SKNode!
    var borderBody: SKPhysicsBody!

    var gType = gameType.twoPlayer
    var isHost = false
    let loadNode = SKNode()
    var sensitivity: Float!
    var AIDifficulty: Int!
    var cAggro:Int?
    var cDef:Int?
    var computerCheckPoint:Double = 2
    
    let goalDelay = Timer()
    let gameTimer = Timer()
    var clockBackground:SKShapeNode?
    let clock = SKLabelNode(fontNamed: "Optima")
    
    var winPoints: Int?
    var baseTime: TimeInterval?
    var gameTime: TimeInterval?
    
    
    var mode = Mode.threeMinute
    var playerOption = PlayerOption.three
    var goalPostA1: GoalPost!
    var goalPostA2: GoalPost!
    var goalPostB1: GoalPost!
    var goalPostB2: GoalPost!
    
    var scoreBoard: ScoreBoard!
    var lastPoint = false
    var turnA = true
    var scoreA = 0
    var scoreB = 0
    
    var scoreBackground:SKSpriteNode!
    var score = SKLabelNode(fontNamed: "Optima")
    
    var timer: Foundation.Timer?
    
    
    var moveTimer:Timer?
    override init(size:CGSize){
        super.init(size: size)
        scoreBoard = ScoreBoard(sender: self)
        let background = SKSpriteNode(imageNamed: "SoccerField")
        scoreBoard.label.fontName = "Optima"
        
        scoreBackground = SKSpriteNode(color: UIColor.white
            , size: CGSize(width: 800*scalerX,height: 200*scalerY))
        scoreBackground.addChild(score)
        scoreBackground.zPosition = 4
        score.fontSize = 50
        score.fontColor = UIColor.black
        scoreBackground.position = CGPoint(x: frame.midX, y: 1.3*frame.midY)
        score.zPosition = 2
        
        addChild(scoreBackground)
        addChild(scoreBoard)
        scoreBoard.position = CGPoint(x: frame.midX,y: 60*scalerY)
        scoreBoard.zPosition = 4
        
        background.position = CGPoint(x:frame.midX, y:frame.midY)
        background.size = self.frame.size
        background.zPosition=1.1
        addChild(background)
        // set rectangular border around screen
        borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.linearDamping = 0
        borderBody.angularDamping = 0
        borderBody.isDynamic = false
        borderBodyNode = SKNode()
        borderBodyNode.physicsBody = borderBody
        borderBodyNode.name = "edge"
        self.addChild(borderBodyNode)
        self.physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        // make soccer nets
        let netTexture = SKTexture(imageNamed: "SoccerNet")
        let netSize = CGSize(width: 80*scalerX, height: 240*scalerY)
        let leftSoccerNet = SKSpriteNode(texture: netTexture,color: UIColor.clear, size: netSize)
        let rightSoccerNet = SKSpriteNode(texture: netTexture,color: UIColor.clear, size: netSize)
        rightSoccerNet.position = CGPoint(x: 1096*scalerX, y: frame.midY)
        leftSoccerNet.position = CGPoint(x:40*scalerX, y: frame.midY)
        rightSoccerNet.zRotation = CGFloat(M_PI)
        rightSoccerNet.zPosition = 3
        leftSoccerNet.zPosition = 3
        addChild(leftSoccerNet)
        addChild(rightSoccerNet)
        
        // set goal posts in place
        let actualSize = CGSize(width: 80*scalerX, height: 5*scalerX)
        goalPostA1 = GoalPost(actualSize: actualSize)
        goalPostA2 = GoalPost(actualSize: actualSize)
        goalPostB1 = GoalPost(actualSize: actualSize)
        goalPostB2 = GoalPost(actualSize: actualSize)
        goalPostA1.position = CGPoint(x: 40*scalerX, y: 440*scalerY)
        goalPostA2.position = CGPoint(x: 40*scalerX, y: 200*scalerY)
        goalPostB1.position = CGPoint(x: 1096*scalerX, y: 440*scalerY)
        goalPostB2.position = CGPoint(x: 1096*scalerX, y: 200*scalerY)
        self.addChild(goalPostA1)
        self.addChild(goalPostA2)
        self.addChild(goalPostB1)
        self.addChild(goalPostB2)
        ball.zPosition = 2
        setPosition()
        self.addChild(ball)
        moveTimer = Timer()
        // set up clock
        clockBackground = SKShapeNode(rect: CGRect(x: -50*scalerX,y: -25*scalerY,width: 100*scalerX,height: 50*scalerY), cornerRadius: 10)
        clockBackground!.fillColor = UIColor.black
        clockBackground!.strokeColor = UIColor.white
        clockBackground!.alpha = 0.7
        clock.fontSize = 15
        clockBackground!.position = CGPoint(x: frame.midX, y: 7/4*frame.midY)
        clock.zPosition = 2
        clock.position = CGPoint(x: 0,y: -8*scalerY)
        clock.fontColor = UIColor.white
        gameTimer.start()
        clockBackground!.addChild(clock)
        clockBackground!.zPosition = 4
        self.addChild(clockBackground!)
        clockBackground?.isHidden = true
        loadNode.physicsBody = SKPhysicsBody(circleOfRadius: 5*scalerX)
        loadNode.physicsBody!.categoryBitMask = 5
        loadNode.physicsBody!.collisionBitMask = 5
        loadNode.physicsBody!.contactTestBitMask = 5
        loadNode.name = "loadNode"
        
        
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func captureGamePosition(){
        
    }
    func didBegin(_ contact: SKPhysicsContact){
        let ballVelocity = ball.physicsBody!.velocity
        if (contact.bodyA == borderBody && contact.bodyB == ball.physicsBody!) || (contact.bodyB == borderBody && contact.bodyA == ball.physicsBody!){
            if 0 <= ballVelocity.dx && ballVelocity.dx < 20{
                ball.physicsBody!.velocity = CGVector(dx: 20,dy: ball.physicsBody!.velocity.dy)
            }
            if -20 < ballVelocity.dx && ballVelocity.dx < 0 {
                ball.physicsBody!.velocity = CGVector(dx: -20, dy: ball.physicsBody!.velocity.dy)
            }
            if 0 <= ballVelocity.dy && ballVelocity.dy < 20{
                ball.physicsBody!.velocity = CGVector(dx: ball.physicsBody!.velocity.dx,dy: 20)
            }
            if -20 < ballVelocity.dy && ballVelocity.dy < 0{
                ball.physicsBody!.velocity = CGVector(dx: ball.physicsBody!.velocity.dx,dy: -20)
            }
        }
//        if gType == .twoPhone && isHost{
//            viewController.parentVC.gameService.sendPositionMove(contact.bodyA.node!.name!, positionA: contact.bodyA.node!.position, velocityA: contact.bodyA.velocity,  nodeB: contact.bodyB.node!.name!, positionB: contact.bodyB.node!.position, velocityB: contact.bodyB.velocity)
//        }
    }
    func didEnd(_ contact: SKPhysicsContact) {
//        if gType == .twoPhone && isHost{
//            viewController.parentVC.gameService.sendPositionMove(contact.bodyA.node!.name!, positionA: contact.bodyA.node!.position, velocityA: contact.bodyA.velocity,  nodeB: contact.bodyB.node!.name!, positionB: contact.bodyB.node!.position, velocityB: contact.bodyB.velocity)
//        }
    }
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        scoreBackground.alpha = 0.0

        // put ball in middle
        
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
            clock.text = gameTimer.secondsToString(baseTime!)
            clockBackground?.isHidden = false
        }
        addPlayers()
        for node in children{
            if node != loadNode{
                if let body = node.physicsBody{
                    body.collisionBitMask = 1
                    body.contactTestBitMask = 1
                    body.categoryBitMask = 1
                }
            }
        }
        if gType == .twoPhone{
            moveTimer?.pause()
            self.isUserInteractionEnabled = false
        }
        if gType == .onePlayer && AIDifficulty == 5{
            timeLimit = 4.5
        }
        restart()
        updateLighting()
        Foundation.Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateLighting), userInfo: nil, repeats: false)
    }
    func sendPosition(){
        viewController.parentVC.gameService.sendPosition(self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)

            if gType == .twoPlayer || (gType == .onePlayer && turnA) || gType == .twoPhone && turnA{
                if (node is Player){
                    let touchedPlayer = (node as! Player)
                    if touchedPlayer.mTeamA == turnA {
                        selectedPlayer = touchedPlayer
                        playerSelected = true
                        startPosition = location
                        selectedPlayer!.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.4, duration: 0))
                    }
                }
                else{
                    for player in players{
                        if player.mTeamA == turnA && playerSelected == false{
                            if distance(player.position, point2: location) < player.size.width*1.5 {
                                selectedPlayer = player
                                playerSelected = true
                                startPosition = player.position
                                selectedPlayer!.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.4, duration: 0))
                            }
                        }
                    }
                }
            }
        }
    }
        
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        if (playerSelected == true) {
            
            let xMovement = CGFloat(sensitivity)*(touches.first!.location(in: self).x - startPosition!.x)
            let yMovement = CGFloat(sensitivity)*(touches.first!.location(in: self).y - startPosition!.y)
            selectedPlayer!.physicsBody!.velocity = CGVector(dx: xMovement, dy: yMovement)
            
            if gType == .twoPhone{
                viewController.parentVC.gameService.sendMove(selectedPlayer!, velocity: selectedPlayer!.physicsBody!.velocity, position: selectedPlayer!.position)
                if !isHost{
                    selectedPlayer!.physicsBody!.velocity = CGVector(dx: xMovement*dampingFactor, dy: yMovement*dampingFactor)
                }
            }
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
   
    override func update(_ currentTime: TimeInterval) {
//        if lastPoint{
//            
//            gamePositions.append([(ball, ball.position,ball.physicsBody!.velocity)],currentTime as Double)
//            for player in players{
//                gamePositions.0.append((player,player.position,player.physicsBody!.velocity))
//            }
//        }
        if gType == .twoPhone && isHost{
            if loaded{
                viewController.parentVC.gameService.sendPosition(self)
                viewController.parentVC.gameService.sendVelocities(self)
            }
            if !loaded{
                viewController.parentVC.gameService.sendLoad(loadNode)
            }
        }
        
        if (!goalAccounted && 200*scalerY < ball.position.y && ball.position.y < 440*scalerY){
            if ball.position.x<60*scalerX{
                self.reset(false)
                if gType == .twoPhone && isHost && viewController.parentVC.gameService.connectedDevice != nil{
                    viewController.parentVC.gameService.stringSend(String(format: "%@ %@ %@","misc", "goal", false.toString()))
                }
            }
            else if 1076*scalerX < ball.position.x {
                if gType == .twoPhone && isHost && viewController.parentVC.gameService.connectedDevice != nil{
                    viewController.parentVC.gameService.stringSend(String(format:"%@ %@ %@","misc", "goal", true.toString()))
                }
                self.reset(true)
            }
        }
        
        if gType == .onePlayer && !turnA{
            computerMove()
        }
        
        if(moveTimer!.getElapsedTime() > 5){
            switchTurns()
        }
        if mode.getType() == .timed && !gameEnded{
            showTime()
        }
        if (goalDelay.getElapsedTime()>2 && !gameEnded){
            scoreBackground.fadeOut()
            setDynamicStates(true)
            moveTimer?.restart()
            if mode.getType() == .timed{
                gameTimer.start()
            }
            setPosition()
            isUserInteractionEnabled = true
            if ownGoal{
                switchTurns()
                ownGoal = false
            }
        }
        if goalDelay.getElapsedTime()>3{
            goalDelay.reset()
            goalAccounted = false
        }
        /* Called before each frame is rendered */
    }
    
    func reset(_ scoreGoal: Bool){
        // reset position of all players and ball
        goalAccounted = true
        if playerSelected{
            playerSelected = false
            selectedPlayer!.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: -0.7, duration: 0.00001))
        }
        if turnA == scoreGoal{
            ownGoal = true
        }
        moveTimer?.reset()
        isUserInteractionEnabled = false
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
            if scoreA == winPoints!-1 || scoreB == winPoints!-1{
                lastPoint = true
            }
        }
            
        else{
            score.text = String.localizedStringWithFormat("%d - %d", scoreA, scoreB)
        }

        if mode.getType() == .timed{
            gameTimer.pause()
        }
        if gType == .onePlayer{
            firstTurn = true
        }
        goalDelay.start()
        
    }
    
    
    func setDynamicStates(_ isDynamic: Bool){
        for player in players{
            player.physicsBody!.isDynamic = isDynamic
        }
        ball.physicsBody!.isDynamic = isDynamic
    }
    
    
    
    func switchTurns(){
        turnA = !turnA
        if gType == .twoPhone && isHost && !isSynced{
//            if mode.getType() == .timed{
//                viewController.parentVC.gameService.sendSync(turnA, time: String(gameTime!))
//            }else{
//                viewController.parentVC.gameService.sendSync(turnA, time: "PointMode")
//            }
            isSynced = true
        }
        if playerSelected == true {
            playerSelected = false
        }
        updateLighting()
        moveTimer?.restart()
        
    }
    
    
    func showTime(){
        if let baseTime = baseTime{
            gameTime = baseTime - gameTimer.getElapsedTime()
        }else{
            gameTime = 100
        }
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
            clock.color = UIColor.red
        }
    }
    
    func endGame(){
        goalDelay.reset()
        gameEnded = true
        setDynamicStates(false)
        scoreBackground.fadeIn()
        if scoreA > scoreB {
            score.text = "PLAYER A WINS"
            if gType == .onePlayer{
                updateStats(true)
                var coinsWon: Int?
                switch (AIDifficulty){
                case 1: coinsWon = (scoreA - scoreB)*difficulty1Multiplier; break
                case 2: coinsWon = Int(round(Double(scoreA - scoreB)*difficulty2Multiplier)); break
                case 3: coinsWon = (scoreA - scoreB)*difficulty3Multiplier; break
                case 4: coinsWon = (scoreA - scoreB)*difficulty4Multiplier; break
                case 5: coinsWon = (scoreA - scoreB)*difficulty5Multiplier; break
                default: break
                }
                viewController.displayEarnings(coinsWon!)
            }
        }
        else if scoreB > scoreA {
            if gType == .onePlayer{
                updateStats(false)
            }
            score.text = "PLAYER B WINS"
        }
        else{
            score.text = "IT'S A TIE!"
        }
        _ = Foundation.Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(goBackToTitle), userInfo: nil, repeats: false)
        gameTimer.elapsedTime = 0

    }
    func goBackToTitle(){
        clockBackground?.isHidden = true
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
    func distance(_ point1: CGPoint, point2: CGPoint) -> CGFloat{
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
        if gType == .twoPhone && !isHost{
            switchTurns()
        }
        gameEnded = false
        isUserInteractionEnabled = true
        scoreBoard.label.text = "0    0"
        updateLighting()

    }
    func addPlayers(){
        for child in children{
            if child is Player{
                child.removeFromParent()
            }else if child.name == "loadNode"{
                child.removeFromParent()
            }
        }
        if gType == .twoPhone{
            if isHost{
                loadNode.position = CGPoint(x: 60*scalerX, y: 60*scalerX)
                loadNode.physicsBody!.velocity = CGVector(dx: 500*scalerX,dy: 0)
            }
            self.addChild(loadNode)
        }
        playerA1 = Player(teamA: true, country: countryA, sender: self, name: "playerA1")
        playerA2 = Player(teamA: true, country: countryA, sender: self, name: "playerA2")
        playerA3 = Player(teamA: true, country: countryA, sender: self, name: "playerA3")
        playerA4 = Player(teamA: true, country: countryA, sender: self, name: "playerA4")
        playerB1 = Player(teamA: false, country: countryB, sender: self, name: "playerB1")
        playerB2 = Player(teamA: false, country: countryB, sender: self, name: "playerB2")
        playerB3 = Player(teamA: false, country: countryB, sender: self, name: "playerB3")
        playerB4 = Player(teamA: false, country: countryB, sender: self, name: "playerB4")
        
        switch (playerOption){
        case PlayerOption.three:
            players = [playerA1, playerA2, playerA3, playerB1, playerB2, playerB3]
            teamA = [playerA1,playerA2,playerA3]
            teamB = [playerB1, playerB2, playerB3]
            break
        case PlayerOption.four:
            players = [playerA1, playerA2, playerA3, playerA4, playerB1, playerB2, playerB3, playerB4]
            teamA = [playerA1, playerA2, playerA3, playerA4]
            teamB = [playerB1, playerB2, playerB3, playerB4]
            break;
        }
        for node in players{
            node.zPosition = 2
            self.addChild(node)
        }
    }
    func computerMove(){
        if moveTimer?.getElapsedTime()<0.1{
            return
        }
        if firstTurn{
            for player in teamA{
                if abs(player.physicsBody!.velocity.dx) > 30 || abs(player.physicsBody!.velocity.dy) > 30{
                    firstTurn = false
                    break
                }
            }
        }
        //let checkInterval = 0.2
        
//        if AIDifficulty >= 3 {
//            if (moveTimer?.getElapsedTime())!>checkInterval*computerCheckPoint && !firstTurn{
//                if straightShot(){
//                    switchTurns()
//                    computerCheckPoint = 2
//                    return
//                }
//                if AIDifficulty >= 4{
//                    if saveGoal(){
//                        switchTurns()
//                        computerCheckPoint = 2
//                        return
//                    }
//                }
//                computerCheckPoint += 1
//            }
//        }
        if AIDifficulty >= 3{
            if !firstTurn{
                if straightShot(){
                    switchTurns()
                    return
                }
                if AIDifficulty >= 4{
                    if saveGoal(){
                        switchTurns()
                        return
                    }
                }
            }
        }
        if moveTimer?.getElapsedTime()>timeLimit{
            if firstTurn{
                firstMove()
                firstTurn = false
            }
            else{
                switch(AIDifficulty){
                case 1: hitBallBasic(true); break
                case 2: hitBallBasic(false); break
                case 3: if !hitBallAdvanced() {hitBallBasic(false)}; break
                case 4: if !hitBallAdvanced() {hitBallBasic(false)}; break
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
                playerB1.physicsBody!.velocity = CGVector(dx: playerA1.position.x-playerB1.position.x,dy: playerA3.position.y - playerB1.position.y)
                addMarker(UIColor.orange, point: playerB1.position)

                break
            case 1:
                playerB2.physicsBody!.velocity = CGVector(dx: playerA1.position.x-playerB2.position.x,dy: playerA3.position.y - playerB2.position.y)
                addMarker(UIColor.orange, point: playerB2.position)
                break
            case 2:
                playerB3.physicsBody!.velocity = CGVector(dx: playerA1.position.x-playerB3.position.x,dy: playerA3.position.y - playerB3.position.y)
                addMarker(UIColor.orange, point: playerB3.position)

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
            var minBar = Int(arc4random_uniform(4))
            while (multiplier <= 0.6){
                let predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier*0.9, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier*0.9)
                if !frame.contains(predictedBallPosition){
                    return false
                }
                if detectBarriers(ball.position, velocity: ball.physicsBody!.velocity, xLimit: predictedBallPosition.x, fromRight: predictedBallPosition.x < ball.position.x)>0{
                    return false
                }
                let toPointVelocity = CGVector(dx: (predictedBallPosition.x-player.position.x),dy: (predictedBallPosition.y - player.position.y))
                let angle = atan(toPointVelocity.dy/toPointVelocity.dx)
                let buffer = player.playerSize.width*5/12
                let predictedPlayerPosition = CGPoint(x: predictedBallPosition.x + cos(angle)*buffer,y: predictedBallPosition.y + sin(angle)*buffer)
                let straightShotVelocity = CGVector(dx: (predictedPlayerPosition.x-player.position.x)/multiplier, dy: (predictedPlayerPosition.y-player.position.y)/multiplier)
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
                        addMarker(UIColor.blue, point: player.position)
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
            addMarker(UIColor.blue, point: shot.0.position)
            return true
        }
        return false
    }
    func detectBarriers(_ startingPoint: CGPoint, velocity: CGVector, xLimit: CGFloat, fromRight: Bool) -> Int{
        var xPosition = (startingPoint.x)
        var yPosition = (startingPoint.y)
        var detectedBarriers = [SKPhysicsBody]()
        var objectAtPoint: SKPhysicsBody?
        detectedBarriers.append(ball.physicsBody!)
        if fromRight{
            while (xPosition > xLimit && xPosition < frame.maxX && yPosition > 0 && yPosition < frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
                objectAtPoint = physicsWorld.body(at: CGPoint(x: xPosition, y: yPosition))
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
                objectAtPoint = physicsWorld.body(at: CGPoint(x: xPosition, y: yPosition))
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
    func detectGoal(_ start: CGPoint, velocity: CGVector, xLimit: CGFloat, fromRight: Bool) -> Bool{
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
                var predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                while !frame.contains(predictedBallPosition) && multiplier > 0{
                    multiplier -= 0.1
                    predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                }
                let toPointVelocity = CGVector(dx: (predictedBallPosition.x-player.position.x),dy: (predictedBallPosition.y - player.position.y))
                let angle = atan(toPointVelocity.dy/toPointVelocity.dx)
                //let buffer = player.playerSize.width*5/12
                let buffer:CGFloat = 0
                let predictedPlayerPosition = CGPoint(x: predictedBallPosition.x + cos(angle)*buffer,y: predictedBallPosition.y + sin(angle)*buffer)
                let blockVelocity = CGVector(dx: (predictedPlayerPosition.x-player.position.x)/multiplier, dy: (predictedPlayerPosition.y-player.position.y)/multiplier)
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
            addMarker(UIColor.yellow, point: bestShot!.0.position)
            return true
        }
        return false
    }
    func dampVelocity(_ velocity: CGVector) -> CGVector{
        return dampVelocity(velocity, maxX: 1000, maxY: 500)
    }
    func dampVelocity(_ velocity: CGVector, maxX: CGFloat, maxY: CGFloat) -> CGVector{
        var dampedVelocity = velocity
        while abs(dampedVelocity.dx)>maxX ||  abs(dampedVelocity.dy) > maxY{
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
                            player.physicsBody!.velocity = CGVector(dx: (frame.midX - player.position.x)/3, dy: (goalPostA1.position.y-player.position.y)/3)
                        }else{
                            player.physicsBody!.velocity = CGVector(dx: (frame.midX - player.position.x)/3, dy: (goalPostA2.position.y - player.position.y)/3)
                        }
                        addMarker(UIColor.black, point: player.position)
                        return true
                    }
                }
                // player in top corners
                if player.position.y > goalPostA1.position.y{
                    if abs(player.physicsBody!.velocity.dx) < 100{
                        player.physicsBody!.velocity = CGVector(dx: (frame.midX - player.position.x)/3, dy: (goalPostA1.position.y-player.position.y)/3)
                        addMarker(UIColor.black, point: player.position)
                        return true
                    }
                    
                }
                //player in bottom corners
                if player.position.y < goalPostA2.position.y{
                    if abs(player.physicsBody!.velocity.dx) < 100{
                        player.physicsBody!.velocity = CGVector(dx: (frame.midX - player.position.x)/3, dy: (goalPostA2.position.y - player.position.y)/3)
                        addMarker(UIColor.black, point: player.position)
                        return true
                    }
                }
            }
        }
        return false
        
    }
    func hitBallBasic(_ random: Bool){
        
        let randomPlayer: UInt32
        switch(playerOption){
        case .three: randomPlayer = arc4random_uniform(3); break
        case .four: randomPlayer = arc4random_uniform(4); break
        }
        let time:CGFloat = 0.5
        let selectedPlayer = teamB[Int(randomPlayer)]
        var ballFuturePosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*time,y: ball.position.y + ball.physicsBody!.velocity.dy*time)
        
        if random{
            if Bool.random(){
                ballFuturePosition.x += CGFloat(arc4random_uniform(32))
            }else{
                ballFuturePosition.x -= CGFloat(arc4random_uniform(32))
            }
            if Bool.random(){
                ballFuturePosition.y += CGFloat(arc4random_uniform(32))
            }else{
                ballFuturePosition.y -= CGFloat(arc4random_uniform(32))
            }
        }
        let shotVelocity = CGVector(dx: (ballFuturePosition.x-selectedPlayer.position.x)/time, dy: (ballFuturePosition.y-selectedPlayer.position.y)/time)
        selectedPlayer.physicsBody!.velocity = random ? dampVelocity(shotVelocity, maxX: CGFloat(300), maxY: CGFloat(180)):dampVelocity(shotVelocity)
        

        addMarker(UIColor.magenta, point: selectedPlayer.position)
    }
    func hitBallAdvanced() -> Bool{
        let ballMultiplier:CGFloat = 0.5
        var ballFuturePosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*ballMultiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*ballMultiplier)
        while !frame.contains(ballFuturePosition){
            let firstVelocity = CGVector(dx: ballFuturePosition.x - ball.position.x, dy: ballFuturePosition.y - ball.position.y)
            if ballFuturePosition.x < 0 || ballFuturePosition.x > frame.maxX{
                if detectBarriers(ball.position,velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: firstVelocity.dx < 0) == 100{
                    return false
                }
                let secondVelocity = CGVector(dx: -firstVelocity.dx, dy: firstVelocity.dy)
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
                let secondVelocity = CGVector(dx: firstVelocity.dx, dy: -firstVelocity.dy)
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
            let playerVelocity = CGVector(dx: 2*ballMultiplier*(ballFuturePosition.x-player.position.x), dy: 2*ballMultiplier*(ballFuturePosition.y - player.position.y))
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
            }
        }
        if let finalShot = bestShot{
            let finalVelocity = dampVelocity(finalShot.1)
            finalShot.0.physicsBody!.velocity = finalVelocity
            addMarker(UIColor.red, point: finalShot.0.position)
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
                player.physicsBody!.velocity = dampVelocity(CGVector(dx: (goalLineB - player.position.x) * deflater, dy: (frame.midY-player.position.y) * deflater))
                addMarker(UIColor.purple, point: player.position)
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
            let shotVelocity = CGVector(dx: closestOpponent.position.x-player.position.x,dy: closestOpponent.position.y-player.position.y)
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
        addMarker(UIColor.brown,point: bestShot!.0.position)
    }
    func addMarker(_ color: UIColor, point: CGPoint){
//        let blue = SKSpriteNode(imageNamed: "PlayerA")
//        blue.runAction(SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 0.0001))
//        blue.size = CGSizeMake(10,10)
//        blue.position = point
//        blue.zPosition = 2
//        blue.name = "blue"
//        addChild(blue)
    }
    func updateStats(_ won: Bool){
        statistics[Stats.totalGames]! += 1
        if won{
            statistics[Stats.totalWon]! += 1
        }
        switch(AIDifficulty){
        case 1:
            statistics[Stats.totalOne]! += 1
            if won{statistics[Stats.oneWon]! += 1}
            break
        case 2:
            statistics[Stats.totalTwo]! += 1
            if won{statistics[Stats.twoWon]! += 1}
            break
        case 3:
            statistics[Stats.totalThree]! += 1
            if won{statistics[Stats.threeWon]! += 1}
            break
        case 4:
            statistics[Stats.totalFour]! += 1
            if won{statistics[Stats.fourWon]! += 1}
            break
        case 5:
            statistics[Stats.totalFive]! += 1
            if won{statistics[Stats.fiveWon]! += 1}
            break
        default:break
        }
        saveStats()
    }
}

