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

class AI {
    var selectedPlayer : Player?
    var startPosition : CGPoint?

    var ball:Ball!
    var moveTimer:Timer!
    var scene:GameScene!

    let timeLimit:Double = 2.5
    
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
        let random = arc4random_uniform(3)
        switch (random){
        case 0:
            scene.playerB1.physicsBody!.velocity = CGVector(dx: scene.playerA1.position.x-scene.playerB1.position.x,dy: scene.playerA3.position.y - scene.playerB1.position.y)
            addMarker(UIColor.orange, point: scene.playerB1.position)
            break
        case 1:
            scene.playerB2.physicsBody!.velocity = CGVector(dx: scene.playerA1.position.x-scene.playerB2.position.x,dy: scene.playerA3.position.y - scene.playerB2.position.y)
            addMarker(UIColor.orange, point: scene.playerB2.position)
            break
        case 2:
            scene.playerB3.physicsBody!.velocity = CGVector(dx: scene.playerA1.position.x-scene.playerB3.position.x,dy: scene.playerA3.position.y - scene.playerB3.position.y)
            addMarker(UIColor.orange, point: scene.playerB3.position)
            break
        default:
            break
        }
    }
    
    func straightShot() -> Bool{
        var bestShot:(Player, CGVector, Int)?
        PLAYERLOOP: for player in scene.teamB{
            var multiplier:CGFloat = 0.3
            var minBar = Int(arc4random_uniform(4))
            while (multiplier <= 0.6){
                let predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier*0.9, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier*0.9)
                if !scene.frame.contains(predictedBallPosition){
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
            while (xPosition > xLimit && xPosition < scene.frame.maxX && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
                objectAtPoint = scene.physicsWorld.body(at: CGPoint(x: xPosition, y: yPosition))
                if objectAtPoint != nil && !detectedBarriers.contains(objectAtPoint!){
                    detectedBarriers.append(objectAtPoint!)
                    if objectAtPoint!.node is GoalPost{
                        return 100
                    }
                }
            }
        }
        else{
            while (xPosition < xLimit && xPosition < scene.frame.maxX && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition += 2
                yPosition += 2*velocity.dy/velocity.dx
                objectAtPoint = scene.physicsWorld.body(at: CGPoint(x: xPosition, y: yPosition))
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
            while (xPosition>xLimit && xPosition < scene.frame.maxX && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition -= 2
                yPosition -= 2*velocity.dy/velocity.dx
            }
        }
        else{
            while (xPosition<xLimit && xPosition > 0 && yPosition > 0 && yPosition < scene.frame.maxY){
                xPosition += 2
                yPosition += 2*velocity.dy/velocity.dx
            }
        }
        if scene.goalPostA1.position.y>yPosition && yPosition > scene.goalPostA2.position.y{
            return true
        }
        return false
        
    }
    
    func saveGoal() -> Bool {
        if detectGoal(ball.position, velocity: ball.physicsBody!.velocity, xLimit: goalLineB, fromRight: false){
            var shots = [(Player, CGVector, Int)]()
            
            var multiplier:CGFloat = 0.3
            for player in scene.teamB{
                var predictedBallPosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*multiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*multiplier)
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
    
    func dampVelocity(_ velocity: CGVector) -> CGVector {
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
        for player in scene.teamB{
            //check corners
            if player.position.x > scene.goalPostB1.position.x-scene.goalPostB1.size.width || player.position.x < scene.goalPostA1.position.x + scene.goalPostA1.size.width{
                // player in opponent goal
                if player.position.x < scene.frame.midX{
                    if player.position.y < scene.goalPostA1.position.y && player.position.y > scene.goalPostA2.position.y{
                        if Bool.random(){
                            player.physicsBody!.velocity = CGVector(dx: (scene.frame.midX - player.position.x)/3, dy: (scene.goalPostA1.position.y-player.position.y)/3)
                        }else{
                            player.physicsBody!.velocity = CGVector(dx: (scene.frame.midX - player.position.x)/3, dy: (scene.goalPostA2.position.y - player.position.y)/3)
                        }
                        addMarker(UIColor.black, point: player.position)
                        return true
                    }
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
        let shotVelocity = CGVector(dx: (ballFuturePosition.x-selectedPlayer.position.x)/time, dy: (ballFuturePosition.y-selectedPlayer.position.y)/time)
        selectedPlayer.physicsBody!.velocity = random ? dampVelocity(shotVelocity, maxX: CGFloat(300), maxY: CGFloat(180)):dampVelocity(shotVelocity)
        
        
        addMarker(UIColor.magenta, point: selectedPlayer.position)
    }
    
    func hitBallAdvanced() -> Bool{
        let ballMultiplier:CGFloat = 0.5
        var ballFuturePosition = CGPoint(x: ball.position.x + ball.physicsBody!.velocity.dx*ballMultiplier, y: ball.position.y + ball.physicsBody!.velocity.dy*ballMultiplier)
        while !scene.frame.contains(ballFuturePosition){
            let firstVelocity = CGVector(dx: ballFuturePosition.x - ball.position.x, dy: ballFuturePosition.y - ball.position.y)
            if ballFuturePosition.x < 0 || ballFuturePosition.x > scene.frame.maxX{
                if detectBarriers(ball.position,velocity: firstVelocity, xLimit: ballFuturePosition.x, fromRight: firstVelocity.dx < 0) == 100{
                    return false
                }
                let secondVelocity = CGVector(dx: -firstVelocity.dx, dy: firstVelocity.dy)
                if ballFuturePosition.x < 0{
                    ballFuturePosition.x = -ballFuturePosition.x
                }
                else if ballFuturePosition.x > scene.frame.maxX{
                    ballFuturePosition.x = 2*scene.frame.maxX-ballFuturePosition.x
                }
                if detectBarriers(ball.position,velocity: secondVelocity, xLimit: ballFuturePosition.x, fromRight: secondVelocity.dx < 0) == 100{
                    return false
                }
                
            }
            if ballFuturePosition.y < 0 || ballFuturePosition.y>scene.frame.maxY{
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
                else if ballFuturePosition.y > scene.frame.maxY{
                    ballFuturePosition.y = 2*scene.frame.maxY-ballFuturePosition.y
                }
            }
        }
        var shots = [(Player, CGVector, Int)]()
        for player in scene.teamB{
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
        if ball.position.x < scene.frame.midX{
            return false
        }
        let deflater:CGFloat = 2/3
        for player in scene.teamB{
            if player.position.x < scene.frame.maxX/3{
                player.physicsBody!.velocity = dampVelocity(CGVector(dx: (goalLineB - player.position.x) * deflater, dy: (scene.frame.midY-player.position.y) * deflater))
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
            let shotVelocity = CGVector(dx: (closestOpponent.position.x-player.position.x) * velFactor, dy: (closestOpponent.position.y-player.position.y) * velFactor)
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
            let blue = SKSpriteNode(imageNamed: "PlayerA")
            blue.run(SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.0001))
            blue.size = CGSize(width: 10, height: 10)
            blue.position = point
            blue.zPosition = 2
            blue.name = "blue"
            scene.addChild(blue)
    }

    
}
