//
//  PeerToPeerGameConnection.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 4/3/17.
//  Copyright © 2017 HS. All rights reserved.
//

import Foundation
import UIKit

// MARK: Connection Manager Delegate

extension PlayViewController : ConnectionManagerDelegate {
    
    func connectedDevicesChanged(_ manager: ConnectionManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            //self.hostedGames = connectedDevices
            //self.gameTableView.reloadData()
        }
    }
    
    func receivePause(_ manager: ConnectionManager, pauseType: String){
        print("recievePause")
        switch pauseType{
        case "pause":self.scene.viewController.PauseClicked(self); break
        case "resume": self.scene.viewController.pauseVC.Resume(self); break
        case "quit": self.scene.viewController.pauseVC.Quit(self); break
        case "restart": self.scene.viewController.pauseVC.Restart(self);break
        default: break
        }
    }
    
    func receiveMisc(_ manager:ConnectionManager, message: [String]){
        switch(message[0]){
        case "goal":
            if !scene.goalAccounted{
                for player in scene.players {
                    player.unHighlight()
                }
                scene.updateLighting()
                scene.reset(!message[1].toBool()!)
                break
            }
        case "loaded":
            print("LOADED")
            
            self.scene.viewController.Dimmer?.fadeOut(0.5)
            self.scene.viewController.loadingView.fadeOut(0.5)
            scene.loaded = true
            scene.restart()
            scene.isUserInteractionEnabled = true
            
        default: break
        }
    }
    
    func receivePositionMove(_ manager: ConnectionManager, positionMove: [String]){
        print("receivePositionMove")
        OperationQueue.main.addOperation({
            let nameA = positionMove[0]
            //let positionA = CGPointMake(screenWidth-positionMove[1].toFloat()*self.scaleFactorX, positionMove[2].toFloat()*self.scaleFactorY)
            let velocityA = CGVector(dx: -positionMove[3].toFloat()*self.scaleFactorX,dy: positionMove[4].toFloat()*self.scaleFactorY)
            let nameB = positionMove[5]
            //let positionB = CGPointMake(screenWidth-positionMove[6].toFloat()*self.scaleFactorX, positionMove[7].toFloat()*self.scaleFactorY)
            
            let velocityB = CGVector(dx: -positionMove[8].toFloat()*self.scaleFactorX, dy: positionMove[9].toFloat()*self.scaleFactorY)
            
            let nodeA = self.scene.childNode(withName: self.convertTeams(nameA))!
            let nodeB = self.scene.childNode(withName: self.convertTeams(nameB))!
            if nodeA != self.scene.borderBodyNode{
                nodeA.physicsBody!.velocity = CGVector(dx: velocityA.dx , dy: velocityA.dy )
            }
            if nodeB != self.scene.borderBodyNode{
                nodeB.physicsBody!.velocity = velocityB
            }
        })
    }
    
    func receiveVelocities(_ manager: ConnectionManager, velocities:[String]){
        OperationQueue.main.addOperation{
            let ballVelocity = CGVector(dx: -velocities[0].toFloat()*self.scaleFactorX, dy: velocities[1].toFloat()*self.scaleFactorY)
            self.scene.ball.physicsBody!.velocity = ballVelocity
            var i = 2
            while i < velocities.count{
                let velocity = CGVector(dx: -velocities[i].toFloat()*self.scaleFactorX, dy: velocities[i+1].toFloat()*self.scaleFactorY)
                self.scene.players[self.convertToIndex(i)].physicsBody!.velocity = velocity
                i+=2
            }
        }
    }
    
    func receiveStart(_ manager: ConnectionManager, settings:[String]){
        DispatchQueue.main.async(execute: {
            self.connectedDevice = self.gameService.connectedDevice!.first?.displayName
            self.gameService.getServiceBrowser().stopBrowsingForPeers()
            self.gameService.getServiceAdvertiser().stopAdvertisingPeer()
            print("receiveStart")
            if !self.scene.isHost{
                self.scene.mode = stringMode[settings[0]]!
                self.scene.gameTimer.restart()
                defaultFriction = Float(settings[4].toFloat())
                //self.gameService.sendPositionVelocity(self.scene)
            }
            if self.scene.countryB != settings[1] {
                self.scene.countryB = settings[1]
                self.scene.playersAdded = false
            }
            self.scaleFactorX = screenWidth/settings[2].toFloat()
            self.scaleFactorY = screenHeight/settings[3].toFloat()
            if !self.sentData{
                self.gameService.sendStart(self.scene)
                self.sentData = true
            }
            self.moveToScene()
            self.timer.restart()
        })
    }
    
    func receiveSync(_ manager: ConnectionManager, turn: String) {
        if turn.toBool()! {
            if scene.turnA {
                scene.switchTurns()
            } else {
                scene.moveTimer?.restart()
            }
        } else {
            if !scene.turnA {
                scene.switchTurns()
            } else {
                scene.moveTimer?.restart()
            }
        }
    }
    
    func receiveMove(_ manager: ConnectionManager, move: [String]) {
        DispatchQueue.main.async(execute: {
            OperationQueue.main.addOperation {
                let playerName = self.convertTeams(move[0])
                let velocityX = -move[1].toFloat()*self.scaleFactorX
                let velocityY = move[2].toFloat()*self.scaleFactorY
                var position = CGPoint(x: screenWidth-move[3].toFloat()*self.scaleFactorX, y: move[4].toFloat()*self.scaleFactorY)
                
                for player in self.scene.teamB{
                    if playerName == player.name{
                        player.unHighlight()
                        player.changeColorDark()
                        player.changeColorBright()
                        self.scene.updateLighting()
                        player.physicsBody!.velocity = CGVector(dx: velocityX, dy: velocityY)
                        let lagTime = CGFloat(Date.timeIntervalSinceReferenceDate) - move[5].toFloat()
                        let currentPosition = player.position
                        // add adjustment for lag
                        if !self.scene.isHost {
                            position.x += lagTime * velocityX
                            position.y += lagTime * velocityY
                        }
                        // take average of currentPosition and new position
                        position.x = (position.x + currentPosition.x)/2
                        position.y = (position.y + currentPosition.y)/2
                        player.position = position
                        if self.scene.isHost {
                            self.scene.switchTurns()
                        }
                        break
                    }
                }
            }
        })
    }
    
    func receivePositions(_ manager: ConnectionManager, positions: [String]){
        print("receivePositions \(timer.getElapsedTime())")
        OperationQueue.main.addOperation{
            let ballPosition = CGPoint(x: screenWidth - positions[0].toFloat()*self.scaleFactorX, y: positions[1].toFloat()*self.scaleFactorY)
            self.scene.ball.position = ballPosition
            var i = 2
            while i < positions.count{
                let point = CGPoint(x: screenWidth - positions[i].toFloat()*self.scaleFactorX, y: positions[i+1].toFloat()*self.scaleFactorY)
                self.scene.players[self.convertToIndex(i)].position = point
                i+=2
            }
        }
    }
    
    func receivePositionVelocity(_ manager: ConnectionManager, positionVelocity: [String]) {
        OperationQueue.main.addOperation{
            let n = positionVelocity.count - 1
            var transition = true
            if n%2 == 1 {
                //transition = false
            }
            var positions = [CGFloat]()
            var velocities = [CGFloat]()
            var j = 0
            if self.scene.justMadeMove {
                self.timer.restart()
                self.scene.justMadeMove = false
            }
            while j < n/2 {
                positions.append(screenWidth - positionVelocity[j].toFloat() * self.scaleFactorX)
                positions.append(positionVelocity[j+1].toFloat() * self.scaleFactorY)
                j += 2
            }
            while j < n {
                velocities.append(-positionVelocity[j].toFloat() * self.scaleFactorX)
                velocities.append(positionVelocity[j+1].toFloat() * self.scaleFactorY)
                j += 2
            }
            var lagTime = CGFloat(Date.timeIntervalSinceReferenceDate) - positionVelocity[n].toFloat()
            lagTime *= 0.5
            let ballVelocity = CGVector(dx: velocities[0], dy: velocities[1])
            
            
            var newBallPosition = CGPoint(x: positions[0] + lagTime * ballVelocity.dx, y: positions[1] + lagTime * ballVelocity.dy)
            if transition {
                let currentPosition = self.scene.ball.position
                newBallPosition.x = (newBallPosition.x + currentPosition.x*2)/3
                newBallPosition.y = (newBallPosition.y + currentPosition.y*2)/3
            }
            self.scene.ball.position = newBallPosition
            if !self.scene.isHost {
                self.scene.ball.physicsBody!.velocity = ballVelocity
            }
            
            var i = 2
            while i < positions.count{
                var position = CGPoint(x: positions[i], y: positions[i+1])
                position.x += lagTime * velocities[i]
                position.y += lagTime * velocities[i+1]
                
                let velocity = CGVector(dx: velocities[i], dy: velocities[i+1])
                let currentPlayer = self.scene.players[self.convertToIndex(i)]
                let currentPosition = currentPlayer.position
                if transition {
                    position.x = (currentPosition.x * 2 + position.x)/3
                    position.y = (currentPosition.y * 2 + position.y)/3
                }
                
                currentPlayer.position = position
                if !self.scene.isHost {
                    currentPlayer.physicsBody!.velocity = velocity
                }
                i+=2
            }
            //self.gameService.sendPositionVelocity(self.scene)
        }
    }
    
    func receiveHighlight(_ manager: ConnectionManager, playerName: String) {
        OperationQueue.main.addOperation{
            let playerBName = self.convertTeams(playerName)
            for player in self.scene.teamB {
                if player.name == playerBName {
                    player.highlight()
                    return
                }
            }
        }
    }
    
    func convertToIndex(_ index: Int) -> Int{
        let rawIndex = index/2-1
        switch(scene.playerOption){
        case .three:
            if rawIndex <= 2{
                return rawIndex + 3
            }
            return rawIndex-3
        case .four:
            if rawIndex <= 3{
                return rawIndex+4
            }; return rawIndex-4
        }
    }
    func convertTeams(_ player:String)->String{
        var newPlayer = player
        if player.characters.count == 8{
            if player[6]=="A"{
                newPlayer=player.replace("A",withString: "B")
            } else{
                newPlayer = player.replace("B", withString: "A")
            }
            return newPlayer
        }
        return player
    }
    func moveToScene(){
        if movedToScene {
            return
        }
        let gameVC = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.scene = scene
        gameVC.parentVC = self
        scene.viewController = gameVC
        scene.gType = .twoPhone
        self.movedToScene = true
        // gameService.getServiceBrowser().stopBrowsingForPeers()
        // gameService.getServiceAdvertiser().stopAdvertisingPeer()
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    func toFloat() -> CGFloat{
        return CGFloat((self as NSString).doubleValue)
    }
    func toBool() -> Bool?{
        if self == "true"{
            return true
        }else if self == "false"{
            return false
        }
        return nil
    }
}

extension Bool{
    func toString() -> String{
        if self{
            return "true"
        }
        return "false"
    }
}