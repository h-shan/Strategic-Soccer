//
//  PlayViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/20/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
import Foundation

class PlayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var scene: GameScene!
    let gameService = ConnectionManager()
    var hostedGames = [String]()
    var otherScreenSize : CGRect!
    var scaleFactorX: CGFloat = 0
    var scaleFactorY: CGFloat = 0
    var parentVC: TitleViewController!
    var connectedDevice: String?
    var sentData = false
    var sentPause = false
    var sentPauseAction = false
    
    let timer = Timer()
    
    @IBOutlet weak var SinglePlayer: UIButton!
    @IBOutlet weak var TwoPlayers: UIButton!
    @IBOutlet weak var ConnectToAnotherDevice: UIButton!
    @IBOutlet weak var ConnectionView: UIView!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var JoinGame: UIButton!
    @IBOutlet weak var HostGame: UIButton!
    @IBOutlet weak var BackButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var BackButtonHeight: NSLayoutConstraint!
    @IBAction func backButton(_ sender: AnyObject){
        _ = navigationController?.popViewController(animated: true)
        gameService.session.disconnect()
    }
    @IBAction func showConnections(_ sender: AnyObject){
        ConnectionView.isHidden = false
    }
    @IBAction func hostGame(_ sender: AnyObject){
        gameService.getServiceAdvertiser().startAdvertisingPeer()
        gameService.getServiceBrowser().startBrowsingForPeers()
        self.gameTableView.reloadData()
        HostGame.isUserInteractionEnabled = false
        HostGame.alpha = 0.5
        scene.isHost = true
    }
    
    @IBAction func joinGame(_ sender: AnyObject){
        gameService.sendStart(self.scene)
        sentData = true
        scene.isHost = false
        JoinGame.alpha = 0.5
        JoinGame.isUserInteractionEnabled = false
    }
    
    @IBAction func hideConnections(_ sender: AnyObject){
        ConnectionView.isHidden = true
        gameService.getServiceAdvertiser().stopAdvertisingPeer()
        gameService.getServiceBrowser().stopBrowsingForPeers()
        gameService.session.disconnect()
        self.gameTableView.reloadData()
        HostGame.isUserInteractionEnabled = true
        HostGame.alpha = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConnectToAnotherDevice.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameService.delegate = self
        setBackground()
        BackButtonWidth.constant = 80/568*screenWidth
        BackButtonHeight.constant = 60/568*screenWidth
        let buttons:[UIButton] = [SinglePlayer, TwoPlayers, ConnectToAnotherDevice, JoinGame, HostGame]
        formatMenuButtons(buttons)
        
        // set ConnectionView.isHidden to false to disable connectivity
        ConnectionView.isHidden = true
        ConnectionView.layer.borderWidth = 5
        ConnectionView.layer.borderColor = UIColor.black.cgColor
        JoinGame.alpha = 0.5
        JoinGame.isUserInteractionEnabled = false
        scene.countryA = parentVC.playerA
        scene.countryB = parentVC.playerB
        scene.addPlayers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! GameViewController
        destinationVC.scene = scene
        destinationVC.parentVC = self
        switch(segue.identifier!){
        case "TwoPlayersSegue":
            scene.gType = .twoPlayer
            break
        case "SinglePlayerSegue":
            scene.gType = .onePlayer
            break
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connectedDevice = self.hostedGames[indexPath.row]
        self.JoinGame.alpha = 1
        self.JoinGame.isUserInteractionEnabled = true
        gameService.connectToDevice(connectedDevice!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = hostedGames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostedGames.count
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
extension PlayViewController : ConnectionManagerDelegate {
    
    func connectedDevicesChanged(_ manager: ConnectionManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.hostedGames = connectedDevices
            self.gameTableView.reloadData()
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
            print(scene.isUserInteractionEnabled)

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
            print("receiveStart")
            if !self.scene.isHost{
                self.scene.mode = stringMode[settings[0]]!
                self.scene.gameTimer.restart()
                defaultFriction = Float(settings[4].toFloat())
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
    
    func receiveSync(_ manager: ConnectionManager, turn: String){
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
        //print("receiveMove \(timer.getElapsedTime())")
        DispatchQueue.main.async(execute: {
            OperationQueue.main.addOperation {
                let playerName = self.convertTeams(move[0])
                let velocityX = -move[1].toFloat()*self.scaleFactorX
                let velocityY = move[2].toFloat()*self.scaleFactorY
                var position = CGPoint(x: screenWidth-move[3].toFloat()*self.scaleFactorX, y: move[4].toFloat()*self.scaleFactorY)
                
                // add adjustment for lag
                let lagTime = CGFloat(Date.timeIntervalSinceReferenceDate) - move[5].toFloat()
                position.x += lagTime * velocityX
                position.y += lagTime * velocityY
                for player in self.scene.teamB{
                    if playerName == player.name{
                        player.physicsBody!.velocity = CGVector(dx: velocityX, dy: velocityY)
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

    func receivePositionVelocity(_ manager: ConnectionManager, positionVelocity: [String]){
        OperationQueue.main.addOperation{
            let n = positionVelocity.count - 1
            var positions = [CGFloat]()
            var velocities = [CGFloat]()
            var j = 0
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
            let ballPosition = CGPoint(x: positions[0], y: positions[1])
            self.scene.ball.position = ballPosition
            let ballVelocity = CGVector(dx: velocities[0], dy: velocities[1])
            self.scene.ball.physicsBody!.velocity = ballVelocity
            
            let lagTime = CGFloat(Date.timeIntervalSinceReferenceDate) - positionVelocity[n].toFloat()
            var i = 2
            
            while i < positions.count{
                var position = CGPoint(x: positions[i], y: positions[i+1])
                
                position.x += lagTime * velocities[i]
                position.y += lagTime * velocities[i+1]
                
                let velocity = CGVector(dx: velocities[i], dy: velocities[i+1])
                self.scene.players[self.convertToIndex(i)].position = position
                self.scene.players[self.convertToIndex(i)].physicsBody!.velocity = velocity
                i+=2
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
            }else{
                newPlayer = player.replace("B", withString: "A")
        }
            return newPlayer
        }
        return player
    }
    func moveToScene(){
        let gameVC = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.scene = scene
        gameVC.parentVC = self
        scene.viewController = gameVC
        scene.loaded = true // changed from false
        scene.gType = .twoPhone
        gameService.getServiceBrowser().stopBrowsingForPeers()
        gameService.getServiceAdvertiser().stopAdvertisingPeer()
        do {
            self.navigationController!.pushViewController(gameVC, animated: true)
        } catch {
            print("error")
        }
        JoinGame.isUserInteractionEnabled = true
        JoinGame.alpha = 1
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




