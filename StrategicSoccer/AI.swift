//
//  AI.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 3/16/17.
//  Copyright © 2017 HS. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

let maxVel:CGFloat = 1000
extension CGVector {
    func getLength() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    mutating func scale(factor: CGFloat) {
        dx *= factor
        dy *= factor
    }
    mutating func compress() {
        let expectedLength:CGFloat = 400
        let ratio = expectedLength/getLength()
        let multiplier = pow(ratio, 0.5)
        scale(factor:multiplier)
    }
    mutating func damp() {
        damp(max: maxVel)
    }
    mutating func damp(max: CGFloat) {
        let ratio = max/getLength()
        if (ratio < 1) {
            scale(factor:ratio)
        }
    }
    mutating func normalize() -> CGVector {
        compress()
        damp()
        return self
    }
}

extension Int {
    func inRange(min:Int, max:Int) -> Bool {
        return self >= min && self <= max
    }
}

class AI {
    var selectedPlayer : Player?
    var startPosition : CGPoint?

    var ball:Ball!
    var moveTimer:Timer!
    var scene:GameScene!

    var markers:[SKSpriteNode] = []
    let timeLimit:Double = 2.5
    var predictedBallPosition:CGPoint?
    var waitTime:Double = 0
    
    init(scene:GameScene) {
        // copy over all necessary variables
        self.ball = scene.ball
        self.scene = scene
        self.moveTimer = scene.moveTimer
    }
    
    func computerMove(){
        // add a delay
        if moveTimer.getElapsedTime()<0.3{
            return
        }
        // check if opponent has made a move
        if scene.firstTurn{
            for player in scene.teamA{
                if abs(player.physicsBody!.velocity.dx) > 30 || abs(player.physicsBody!.velocity.dy) > 30{
                    scene.firstTurn = false
                    break
                }
            }
        }
        if scene.firstTurn{
            firstMove()
            scene.firstTurn = false
            scene.switchTurns()
            return
        }
        if scene.AIDifficulty >= 3{
            if !scene.firstTurn{
                if straightShot(){
                    scene.switchTurns()
                    return
                }
                if scene.AIDifficulty >= 4{
                    if saveGoal(){
                        scene.switchTurns()
                        return
                    }
                }
            }
        }
        if scene.AIDifficulty == 5 {
            if makeWayForGoal() {
                scene.switchTurns()
                return
            }
        }
        if moveTimer.getElapsedTime()>timeLimit{
            switch(scene.AIDifficulty){
            case 1: hitBallBasic(true); break
            case 2: hitBallBasic(false); break
            case 3: if !hitBallAdvanced() {hitBallBasic(false)}; break
            case 4: if !hitBallAdvanced() {hitBallBasic(false)}; break
            case 5: improvePosition(); break
            default: break
            }
            
            scene.computerCheckPoint = 2
            scene.switchTurns()
        }
        
    }
    
    func firstMove(){
        //if playerOption == PlayerOption.three{
        let random = Int(arc4random_uniform(9))
        // adding 10 so that there isn't a free goal
        if random.inRange(min: 0, max: 0) {
            scene.playerB1.physicsBody!.velocity = CGVector(dx: scene.playerA1.position.x-scene.playerB1.position.x + 10,dy: scene.playerA3.position.y - scene.playerB1.position.y)
            addMarker(UIColor.orange, point: scene.playerB1.position)
        } else if random.inRange(min: 1, max: 1) {
            scene.playerB2.physicsBody!.velocity = CGVector(dx: scene.playerA1.position.x-scene.playerB2.position.x + 10,dy: scene.playerA3.position.y - scene.playerB2.position.y)
            addMarker(UIColor.orange, point: scene.playerB2.position)
        } else if random.inRange(min: 2, max: 2) {
            // middle player
            scene.playerB3.physicsBody!.velocity = CGVector(dx: scene.playerA1.position.x-scene.playerB3.position.x + 10,dy: scene.playerA3.position.y - scene.playerB3.position.y)
            addMarker(UIColor.orange, point: scene.playerB3.position)
        } else if random.inRange(min:3, max:5) {
            // left from bottom
            scene.playerB1.physicsBody!.velocity = CGVector(dx: goalLineB - scene.playerB1.position.x, dy: scene.frame.maxY*1/3 - scene.playerB1.position.y)
            addMarker(UIColor.magenta, point: scene.playerB1.position)
        } else if random.inRange(min:6, max:8) {
            // right from bottom
            scene.playerB2.physicsBody!.velocity = CGVector(dx: goalLineB - scene.playerB2.position.x, dy: scene.frame.maxY*2/3 - scene.playerB2.position.y)
            addMarker(UIColor.magenta, point: scene.playerB2.position)
        }
    }
    
    func straightShot() -> Bool{
        var bestShot:(Player, CGVector, Int)?
        let threshold = Int(arc4random_uniform(3))
        PLAYERLOOP: for player in scene.teamB{
            var multiplier:CGFloat = 0.1
            var minBar = 20
            while (multiplier <= 0.6){
                let predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                if !scene.frame.contains(predictedBallPosition){
                    return false
                }
                if detectBarriers(ball.position, velocity: ball.physicsBody!.velocity, xLimit: predictedBallPosition.x, fromRight: predictedBallPosition.x < ball.position.x).count > 0 {
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
                if predictedBallPosition.x < 50*scalerX{
                    multiplier+=0.1
                    continue
                }
                
                if detectGoal(predictedBallPosition, velocity: straightShotVelocity, xLimit: goalLineA, fromRight: true){
                    // detectObstacles
                    let numBar = detectBarriers(player.position, velocity: straightShotVelocity, xLimit: goalLineB, fromRight: true).count
                    if numBar < minBar{
                        self.predictedBallPosition = predictedBallPosition
                        self.waitTime = Double(multiplier)*0.8
                        scene.predictionTimer.restart()
                        bestShot = (player, straightShotVelocity, numBar)
                        minBar = numBar
                    } else if numBar == minBar {
                        if straightShotVelocity.getLength() < bestShot!.1.getLength() {
                            self.predictedBallPosition = predictedBallPosition
                            self.waitTime = Double(multiplier)*0.8
                            scene.predictionTimer.restart()

                            bestShot = (player, straightShotVelocity, numBar)
                        }
                    }
                }
                multiplier += 0.1
            }
        }
        if var shot = bestShot{
            if shot.2 >= threshold {
                return false
            }
            shot.1.compress()
            shot.1.damp()
            shot.0.physicsBody!.velocity = shot.1
            addMarker(UIColor.blue, point: shot.0.position)
            return true
        }
        return false
    }
    
    
    func detectBarriers(_ startingPoint: CGPoint, velocity: CGVector, xLimit: CGFloat, fromRight: Bool) -> [SKPhysicsBody]{
        var xPosition = (startingPoint.x)
        var yPosition = (startingPoint.y)
        var detectedBarriers = [SKPhysicsBody]()
        var objectAtPoint: SKPhysicsBody?
        detectedBarriers.append(ball.physicsBody!)
        if fromRight{
            while (xPosition > xLimit && xPosition < scene.frame.maxX && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
                objectAtPoint = scene.physicsWorld.body(at: CGPoint(x: xPosition, y: yPosition))
                if objectAtPoint != nil && !detectedBarriers.contains(objectAtPoint!){
                    detectedBarriers.append(objectAtPoint!)
                    if objectAtPoint!.node is GoalPost{
                        // fill up detectedBarriers with 10 nodes to increase size
                        for _ in 0..<10 {
                            detectedBarriers.append(SKPhysicsBody())
                        }
                        return detectedBarriers
                    }
                }
            }
        } else{
            while (xPosition < xLimit && xPosition < scene.frame.maxX && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition += 2
                yPosition += 2*velocity.dy/velocity.dx
                objectAtPoint = scene.physicsWorld.body(at: CGPoint(x: xPosition, y: yPosition))
                if objectAtPoint != nil && !detectedBarriers.contains(objectAtPoint!){
                    detectedBarriers.append(objectAtPoint!)
                    if objectAtPoint!.node is GoalPost{
                        // fill up detectedBarriers with 10 nodes to increase size
                        for _ in 0..<10 {
                            detectedBarriers.append(SKPhysicsBody())
                        }
                        return detectedBarriers
                    }
                }
            }
        }
        detectedBarriers.remove(at: 0)
        return detectedBarriers
    }
    
    func detectGoal(_ start: CGPoint, velocity: CGVector, xLimit: CGFloat, fromRight: Bool) -> Bool{
        if (velocity.dx >= 0 && fromRight) || (velocity.dx <= 0 && !fromRight){
            return false
        }
        var xPosition = start.x
        var yPosition = start.y
        if fromRight {
            while (xPosition>xLimit && xPosition < scene.frame.maxX && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
            }
        } else {
            while (xPosition<xLimit && xPosition > 0 && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition += 2
                yPosition += 2*velocity.dy/velocity.dx
            }
        }
        
        if scene.goalPostA1.position.y > yPosition && yPosition > scene.goalPostA2.position.y{
            return true
        }
        return false
        
    }
    
    func saveGoal() -> Bool {
        var predictedBallPosition:CGPoint = CGPoint()
        if ball.position.x < 0.6*scene.frame.maxX {
            return false
        }
        if detectGoal(ball.position, velocity: ball.physicsBody!.velocity, xLimit: goalLineB, fromRight: false){
            var shots = [(Player, CGVector, Int)]()
            
            var multiplier:CGFloat = 0.3
            for player in scene.teamB{
                predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                while !scene.frame.contains(predictedBallPosition) && multiplier > 0{
                    multiplier -= 0.1
                    predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
                }
                let toPointVelocity = CGVector(dx: (predictedBallPosition.x-player.position.x),dy: (predictedBallPosition.y - player.position.y))
                let angle = atan(toPointVelocity.dy/toPointVelocity.dx)
                //let buffer = player.playerSize.width*5/12
                let buffer:CGFloat = 0
                let predictedPlayerPosition = CGPoint(x: predictedBallPosition.x + cos(angle)*buffer,y: predictedBallPosition.y + sin(angle)*buffer)
                let blockVelocity = CGVector(dx: (predictedPlayerPosition.x-player.position.x)/multiplier, dy: (predictedPlayerPosition.y-player.position.y)/multiplier)
                let numBar = detectBarriers(player.position, velocity: blockVelocity, xLimit: goalLineB, fromRight: player.position.x > ball.position.x).count
                shots.append((player,blockVelocity, numBar))
                
            }
            var minBar = shots[0].2
            for shot in shots{
                if shot.2 < minBar{
                    minBar = shot.2
                }
            }
            if minBar >= 10 {
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
            self.predictedBallPosition = predictedBallPosition
            self.waitTime = Double(multiplier)*0.8
            scene.predictionTimer.restart()
            bestShot!.0.physicsBody!.velocity = bestShot!.1.normalize()
            
            addMarker(UIColor.yellow, point: bestShot!.0.position)
            return true
        }
        return false
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
        if clearCorner() {
            return
        }
        if getBehindBall(){
            return
        }
        deflectPlayer()
    }
    
    func outOfCorner() -> Bool{
        for player in scene.teamB{
            //check corners
            if player.position.x > goalLineB || player.position.x < goalLineA{
                // player in opponent goal
                if player.position.x < scene.frame.midX{
                    if Bool.random(){
                        player.physicsBody!.velocity = CGVector(dx: (scene.frame.midX - player.position.x)/3, dy: (scene.goalPostA1.position.y-player.position.y)/3)
                    } else{
                        player.physicsBody!.velocity = CGVector(dx: (scene.frame.midX - player.position.x)/3, dy: (scene.goalPostA2.position.y - player.position.y)/3)
                    }
                    addMarker(UIColor.black, point: player.position)
                    return true
                    
                }
                // player in top corners
                if player.position.y > scene.goalPostA1.position.y{
                    if abs(player.physicsBody!.velocity.dx) < 100{
                        player.physicsBody!.velocity = CGVector(dx: (scene.frame.midX - player.position.x)/3, dy: (scene.goalPostA1.position.y-player.position.y)/3)
                        addMarker(UIColor.black, point: player.position)
                        return true
                    }
                    
                }
                //player in bottom corners
                if player.position.y < scene.goalPostA2.position.y{
                    if abs(player.physicsBody!.velocity.dx) < 100{
                        player.physicsBody!.velocity = CGVector(dx: (scene.frame.midX - player.position.x)/3, dy: (scene.goalPostA2.position.y - player.position.y)/3)
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
        switch(scene.playerOption){
            case .three: randomPlayer = arc4random_uniform(3); break
            case .four: randomPlayer = arc4random_uniform(4); break
        }
        let time:CGFloat = 0.5
        let selectedPlayer = scene.teamB[Int(randomPlayer)]
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
        var shotVelocity = CGVector(dx: (ballFuturePosition.x-selectedPlayer.position.x)/time, dy: (ballFuturePosition.y-selectedPlayer.position.y)/time)
        shotVelocity.normalize()
        selectedPlayer.physicsBody!.velocity = shotVelocity
        
        addMarker(UIColor.magenta, point: selectedPlayer.position)
    }
    
    func hitBallAdvanced() -> Bool{
        
        let ballMultiplier:CGFloat = 0.5
        var ballFuturePosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*ballMultiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*ballMultiplier)
        while !scene.frame.contains(ballFuturePosition){
            let firstVelocity = CGVector(dx: ballFuturePosition.x - ball.position.x, dy: ballFuturePosition.y - ball.position.y)
            if ballFuturePosition.x < 0 || ballFuturePosition.x > scene.frame.maxX{
                if detectBarriers(ball.position,velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: firstVelocity.dx < 0).count >= 10{
                    return false
                }
                let secondVelocity = CGVector(dx: -firstVelocity.dx, dy: firstVelocity.dy)
                if ballFuturePosition.x < 0{
                    ballFuturePosition.x = -ballFuturePosition.x
                }
                else if ballFuturePosition.x > scene.frame.maxX{
                    ballFuturePosition.x = 2*scene.frame.maxX-ballFuturePosition.x
                }
                if detectBarriers(ball.position,velocity: secondVelocity, xLimit: ballFuturePosition.x, fromRight: secondVelocity.dx < 0).count >= 10{
                    return false
                }
                
            }
            if ballFuturePosition.y < 0 || ballFuturePosition.y>scene.frame.maxY{
                if detectBarriers(ball.position, velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: firstVelocity.dx < 0).count >= 10{
                    return false
                }
                let secondVelocity = CGVector(dx: firstVelocity.dx, dy: -firstVelocity.dy)
                if detectBarriers(ball.position, velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: secondVelocity.dx < 0).count >= 10{
                    return false
                }
                if ballFuturePosition.y < 0{
                    ballFuturePosition.y = -ballFuturePosition.y
                }
                else if ballFuturePosition.y > scene.frame.maxY{
                    ballFuturePosition.y = 2*scene.frame.maxY-ballFuturePosition.y
                }
            }
        }
        var shots = [(Player, CGVector, Int)]()
        for player in scene.teamB{
            if (!isGoalie(player: player)) {
                let playerVelocity = CGVector(dx: 2*ballMultiplier*(ballFuturePosition.x-player.position.x), dy: 2*ballMultiplier*(ballFuturePosition.y - player.position.y))
                let numBar = detectBarriers(player.position,velocity: playerVelocity, xLimit: ball.position.x, fromRight: playerVelocity.dx < 0).count
                if playerVelocity.dx < 0{
                    shots.append((player,playerVelocity,numBar))
                }
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
        if var finalShot = bestShot{
            self.predictedBallPosition = ballFuturePosition
            self.waitTime = Double(ballMultiplier)*0.8
            scene.predictionTimer.restart()
            finalShot.0.physicsBody!.velocity = finalShot.1.normalize()
            addMarker(UIColor.red, point: finalShot.0.position)
            return true
        }
        return false
        
    }
    
    func getBehindBall() -> Bool{
        if ball.position.x < scene.frame.midX{
            return false
        }
        var deflater:CGFloat = 0.6
        for player in scene.teamB{
            if player.position.x < scene.frame.maxX/3{
                var vel = CGVector(dx: (goalLineB - player.position.x) * deflater, dy: (scene.frame.midY-player.position.y) * deflater)
                vel.normalize()
                player.physicsBody!.velocity = vel
                addMarker(UIColor.purple, point: player.position)
                return true
            }
        }
        return false
    }
    
    func deflectPlayer(){
        var closestDistance:CGFloat = 1000
        var closestOpponent = scene.playerA1
        for player in scene.teamA{
            if scene.distance(player.position, point2:ball.position) < closestDistance{
                closestDistance = scene.distance(player.position, point2: ball.position)
                closestOpponent = player
            }
        }
        var shots = [(Player,CGVector, Int)]()
        
        let velFactor:CGFloat = 2
        for player in scene.teamB{
            if (!isGoalie(player: player)) {
                let shotVelocity = CGVector(dx: (closestOpponent.position.x-player.position.x) * velFactor, dy: (closestOpponent.position.y-player.position.y) * velFactor)
                let numBar = detectBarriers(player.position,velocity: shotVelocity, xLimit: closestOpponent.position.x, fromRight: shotVelocity.dx < 0).count
                shots.append(player,shotVelocity, numBar)
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
        bestShot!.0.physicsBody!.velocity = bestShot!.1.normalize()
        addMarker(UIColor.brown,point: bestShot!.0.position)
    }
    
    func makeWayForGoal() -> Bool {
        
        if detectGoal(ball.position, velocity: ball.physicsBody!.velocity, xLimit: goalLineA, fromRight: true){
            let bar = detectBarriers(ball.position, velocity: ball.physicsBody!.velocity, xLimit: goalLineA, fromRight: true)
            if (bar.count == 1) {
                var shots = [(Player,CGVector, Int)]()
                let velFactor:CGFloat = 2
                for body in bar {
                    for playerA in scene.teamA {
                        if (body == playerA.physicsBody!) {
                            for player in scene.teamB{
                                let shotVelocity = CGVector(dx: (playerA.position.x-player.position.x) * velFactor, dy: (playerA.position.y-player.position.y) * velFactor)
                                let numBar = detectBarriers(player.position,velocity: shotVelocity, xLimit: playerA.position.x, fromRight: shotVelocity.dx < 0).count
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
                            bestShot!.0.physicsBody!.velocity = bestShot!.1.normalize()
                            addMarker(UIColor.cyan, point: bestShot!.0.position)
                            return true
                        }
                    }
                    for playerB in scene.teamB {
                        if (!isGoalie(player: playerB)) {
                            if (body == playerB.physicsBody!) {
                                if scene.distance(ball.position, point2: ball.position) < 0.3 * scene.frame.maxX {
                                    // try to dodge towards middle of screen
                                    var dodgeVel:CGVector
                                    let velX = ball.physicsBody!.velocity.dx/2
                                    let velY = ball.physicsBody!.velocity.dy/2
                                    dodgeVel = CGVector(dx: velY, dy: -velX)
                                    playerB.physicsBody!.velocity = dodgeVel
                                    addMarker(UIColor.cyan, point: playerB.position)
                                    return true
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    func clearCorner() -> Bool{
        // if ball not in corner or still moving, then don't do anything
        if ball.position.x < goalLineA || ball.position.x > goalLineB {
            return false
        }
        if ball.physicsBody!.velocity.getLength() > 200 {
            return false
        }
        // go through all players and find one that doesn't hit a goal post
        for playerB in scene.teamB {
            if (!isGoalie(player: playerB)) {
                let vel = CGVector(dx: ball.position.x - playerB.position.x, dy: ball.position.y - playerB.position.y)
                let bar = detectBarriers(ball.position, velocity: ball.physicsBody!.velocity, xLimit: goalLineA, fromRight: playerB.position.x > ball.position.x)
                if (bar.count < 10) {
                    playerB.physicsBody?.velocity = vel
                    addMarker(UIColor.gray, point: playerB.position)
                    return true
                }
            }
        }
        return false
    }
    
    func isGoalie(player:Player) -> Bool{
        if (player.position.x > goalLineB) {
            if (player.position.y > scene.goalPostA1.position.y || player.position.y < scene.goalPostA2.position.y) {
                return true
            }
        }
        return false
    }
    
    func addMarker(_ color: UIColor, point: CGPoint){
        let marker = SKSpriteNode(imageNamed: "PlayerA")
        marker.run(SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.0001))
        marker.size = CGSize(width: 10, height: 10)
        marker.position = point
        marker.zPosition = 10 // 2
        marker.name = "marker"
        scene.addChild(marker)
        markers.append(marker)
        // only keep track of last 10
        if markers.count > 10 {
            markers[0].removeFromParent()
            markers.remove(at: 0)
        }
    }

    
}
