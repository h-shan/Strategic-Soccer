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

extension CGPoint {
    func distance(_ point : CGPoint) -> CGFloat{
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx*dx + dy*dy)
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
    var gameTime: TimeInterval!
    
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
    
    var selPlayTimer:Timer?
    var moveTimer:Timer?
    
    var comp:AI!
    let predictionTimer = Timer()
    
    var playersAdded = false
    
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
        
        selPlayTimer = Timer()
        comp = AI(scene: self)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        } else {
//            if (contact.bodyA != ball.physicsBody!) {
//                contact.bodyA.velocity.scale(factor: 0.8)
//            } else {
//                contact.bodyA.velocity.scale(factor: 0.8)
//            }
//            if (contact.bodyB != ball.physicsBody!) {
//                contact.bodyB.velocity.scale(factor: 0.8)
//            } else {
//                contact.bodyB.velocity.scale(factor: 0.8)
//            }
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
        physicsWorld.speed = 1

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
            if let body = node.physicsBody{
                body.collisionBitMask = 1
                body.contactTestBitMask = 1
                body.categoryBitMask = 1
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
        var selPlay: (CGFloat, Player?, CGPoint?) = (0.2 * screenWidth, nil, nil)
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if gType == .twoPlayer || (gType == .onePlayer && turnA) || (gType == .twoPhone && turnA) {
                if let touchedPlayer = node as? Player {
                    if touchedPlayer.mTeamA == turnA {
                        selPlay.1 = touchedPlayer
                        selPlay.2 = location
                        break
                    }
                }
                for player in players{
                    // select closest player within set radius
                    if player.mTeamA == turnA {
                        let dis = player.position.distance(location)
                        if dis < selPlay.0 {
                            selPlay.0 = dis
                            selPlay.1 = player
                            selPlay.2 = location
                        }
                    }
                }
                
            }
        }
        if let touchedPlayer = selPlay.1 {
            selectedPlayer = touchedPlayer
            playerSelected = true
            startPosition = selPlay.2!
            selectedPlayer!.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.4, duration: 0))
            selPlayTimer!.restart()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        if (playerSelected == true) {
            // get time so that we measure velocity of swipe rather than simply distance
            let ms = min(1, CGFloat((selPlayTimer!.getElapsedTime())))
            let xMovement = CGFloat(sensitivity)*(touches.first!.location(in: self).x - startPosition!.x)
            let yMovement = CGFloat(sensitivity)*(touches.first!.location(in: self).y - startPosition!.y)
            let velX = xMovement/pow(ms, 1.0/1.5)
            let velY = yMovement/pow(ms, 1.0/1.5)
            var vel = CGVector(dx: velX, dy: velY)
            vel.damp(max: 1000)
            
            selectedPlayer!.physicsBody!.velocity = vel
            if gType == .twoPhone {
                viewController.parentVC.gameService.sendMove(selectedPlayer!, velocity: selectedPlayer!.physicsBody!.velocity, position: selectedPlayer!.position)
                // this is for exchanging host status, expeimental
                // isHost = false
                if !isHost{
                    selectedPlayer!.physicsBody!.velocity = vel
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
        if gType == .twoPhone && isHost{
            if loaded{
                // viewController.parentVC.gameService.sendPosition(self)
                // viewController.parentVC.gameService.sendVelocities(self)
                viewController.parentVC.gameService.sendPositionVelocity(self)
            }
        }
        if predictionTimer.getElapsedTime() > comp.waitTime {
            predictionTimer.reset()
            comp.addMarker(UIColor.red, point: comp.predictedBallPosition!)
        }
        
        if (!goalAccounted && 200*scalerY < ball.position.y && ball.position.y < 440*scalerY){
            if !(gType == .twoPhone && !isHost) {
                checkGoal()
            }
        }
        
        if gType == .onePlayer && !turnA{
            comp.computerMove()
        }
        
        if(moveTimer!.getElapsedTime() > 5){
            switchTurns()
        }
        if mode.getType() == .timed && !gameEnded{
            showTime()
        }
        if (goalDelay.getElapsedTime()>2 && !gameEnded){
            scoreBackground.fadeOut()
            isUserInteractionEnabled = true
            setDynamicStates(true)
            moveTimer?.restart()
            if mode.getType() == .timed{
                gameTimer.start()
            }
            setPosition()
            goalDelay.reset()
            goalAccounted = false
            if ownGoal{
                switchTurns()
                ownGoal = false
            }
        }
        /* Called before each frame is rendered */
    }
    
    func reset(_ scoreGoal: Bool){
        // reset position of all players and ball
        
        goalAccounted = true
        // unselect any plaers
        if playerSelected{
            playerSelected = false
            selectedPlayer!.run(SKAction.colorize(with: UIColor.gray, colorBlendFactor: -0.7, duration: 0.00001))
        }
        if turnA == scoreGoal{
            ownGoal = true
        }
        moveTimer?.reset()
        isUserInteractionEnabled = false
        
        // update scores
        if scoreGoal{
            scoreA+=1
        } else if !scoreGoal{
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
        } else{
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
            if mode.getType() == .timed{
                viewController.parentVC.gameService.sendSync(turnA, time: String(gameTime!))
                gameTimer.restart()
            }else{
                viewController.parentVC.gameService.sendSync(turnA, time: "PointMode")
            }
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
            updateStats(false)
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
        removeMarkers()
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
        moveTimer?.restart()

    }
    
    func addPlayers(){
        if (!playersAdded) {
            playerA1 = Player(teamA: true, country: countryA, sender: self, name: "playerA1")
            playerA2 = Player(teamA: true, country: countryA, sender: self, name: "playerA2")
            playerA3 = Player(teamA: true, country: countryA, sender: self, name: "playerA3")
            playerA4 = Player(teamA: true, country: countryA, sender: self, name: "playerA4")
            playerB1 = Player(teamA: false, country: countryB, sender: self, name: "playerB1")
            playerB2 = Player(teamA: false, country: countryB, sender: self, name: "playerB2")
            playerB3 = Player(teamA: false, country: countryB, sender: self, name: "playerB3")
            playerB4 = Player(teamA: false, country: countryB, sender: self, name: "playerB4")
            
            playersAdded = true
        }
        
        
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
        for node in self.children {
            if node is Player {
                node.removeFromParent()
            }
        }
        
        for node in players{
            node.zPosition = 2
            self.addChild(node)
        }
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
    
    func removeMarkers() {
        for node in self.children {
            if node.name == "marker" {
                node.removeFromParent()
            }
        }
    }
    
    func checkGoal() {
        if ball.position.x < goalLineA {
            self.reset(false)
            if gType == .twoPhone && isHost && viewController.parentVC.gameService.connectedDevice != nil{
                viewController.parentVC.gameService.stringSend(String(format: "%@ %@ %@","misc", "goal", false.toString()))
            }
        } else if ball.position.x > goalLineB {
            if gType == .twoPhone && isHost && viewController.parentVC.gameService.connectedDevice != nil{
                viewController.parentVC.gameService.stringSend(String(format:"%@ %@ %@","misc", "goal", true.toString()))
            }
            self.reset(true)
        }
    }
}

