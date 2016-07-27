//
//  PlayViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/20/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
var dampingFactor:CGFloat = 0.5
class PlayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var scene: GameScene!
    let gameService = ConnectionManager()
    var hostedGames = [String]()
    var otherScreenSize : CGRect!
    var scaleFactorX: CGFloat = 0
    var scaleFactorY: CGFloat = 0
    var parent: TitleViewController!
    var connectedDevice: String?
    var sentData = false
    var sentPause = false
    var sentPauseAction = false
    @IBOutlet weak var SinglePlayer: UIButton!
    @IBOutlet weak var TwoPlayers: UIButton!
    @IBOutlet weak var ConnectToAnotherDevice: UIButton!
    @IBOutlet weak var ConnectionView: UIView!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var JoinGame: UIButton!
    @IBOutlet weak var HostGame: UIButton!
    @IBOutlet weak var BackButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var BackButtonHeight: NSLayoutConstraint!
    @IBAction func backButton(sender: AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func showConnections(sender: AnyObject){
        ConnectionView.hidden = false
    }
    @IBAction func hostGame(sender: AnyObject){
        gameService.getServiceAdvertiser().startAdvertisingPeer()
        gameService.getServiceBrowser().startBrowsingForPeers()
        self.gameTableView.reloadData()
        HostGame.userInteractionEnabled = false
        HostGame.alpha = 0.5
    }
    @IBAction func joinGame(sender: AnyObject){
        gameService.sendStart(nil, flag: scene.countryA)
        sentData = true
        JoinGame.alpha = 0.5
        JoinGame.userInteractionEnabled = false
    }
    @IBAction func hideConnections(sender: AnyObject){
        ConnectionView.hidden = true
        gameService.getServiceAdvertiser().stopAdvertisingPeer()
        gameService.getServiceBrowser().stopBrowsingForPeers()
        HostGame.userInteractionEnabled = true
        HostGame.alpha = 1
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        gameService.delegate = self
        setBackground()
        BackButtonWidth.constant = 80/568*screenWidth
        BackButtonHeight.constant = 60/568*screenWidth
        let buttons:[UIButton] = [SinglePlayer, TwoPlayers, ConnectToAnotherDevice, JoinGame, HostGame]
        formatMenuButtons(buttons)
        ConnectionView.hidden = true
        ConnectionView.layer.borderWidth = 5
        ConnectionView.layer.borderColor = UIColor.blackColor().CGColor
        JoinGame.alpha = 0.5
        JoinGame.userInteractionEnabled = false
        scene.countryA = parent.playerA
        scene.countryB = parent.playerB
        scene.addPlayers()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! GameViewController
        destinationVC.scene = scene
        destinationVC.parent = self
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        connectedDevice = self.hostedGames[indexPath.row]
        self.JoinGame.alpha = 1
        self.JoinGame.userInteractionEnabled = true
        gameService.connectToDevice(connectedDevice!)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = hostedGames[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostedGames.count
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
extension PlayViewController : ConnectionManagerDelegate {
    func connectedDevicesChanged(manager: ConnectionManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.hostedGames = connectedDevices
            self.gameTableView.reloadData()
        }
    }
    func receivePause(manager: ConnectionManager, pauseType: String){
        switch pauseType{
        case "pause":self.scene.viewController.PauseClicked(0); break
        case "resume": self.scene.viewController.pauseVC.Resume(0); break
        case "quit": self.scene.viewController.pauseVC.Quit(0); break
        case "restart": self.scene.viewController.pauseVC.Restart(0);break
        default: break
        }
    }
    func receiveMisc(manager:ConnectionManager, message: [String]){
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
            scene.loadNode.removeFromParent()
            scene.userInteractionEnabled = true
            print(scene.userInteractionEnabled)

        default: break
        }
    }
    func receivePositionMove(manager: ConnectionManager, positionMove: [String]){
        print("receivePositionMove")
        NSOperationQueue.mainQueue().addOperationWithBlock({
            let nameA = positionMove[0]
            //let positionA = CGPointMake(screenWidth-positionMove[1].toFloat()*self.scaleFactorX, positionMove[2].toFloat()*self.scaleFactorY)
            let velocityA = CGVectorMake(-positionMove[3].toFloat()*self.scaleFactorX*dampingFactor,positionMove[4].toFloat()*self.scaleFactorY*dampingFactor)
            let nameB = positionMove[5]
            //let positionB = CGPointMake(screenWidth-positionMove[6].toFloat()*self.scaleFactorX, positionMove[7].toFloat()*self.scaleFactorY)
            
            let velocityB = CGVectorMake(-positionMove[8].toFloat()*self.scaleFactorX*dampingFactor, positionMove[9].toFloat()*self.scaleFactorY*dampingFactor)
            
            let nodeA = self.scene.childNodeWithName(self.convertTeams(nameA))!
            let nodeB = self.scene.childNodeWithName(self.convertTeams(nameB))!
            if nodeA != self.scene.borderBodyNode{
                //nodeA.position = positionA
                if !self.scene.isHost{
                    nodeA.physicsBody!.velocity = CGVectorMake(velocityA.dx * dampingFactor, velocityA.dy * dampingFactor)
                }
                else{
                    nodeA.physicsBody!.velocity = velocityA
                }
            }
            if nodeB != self.scene.borderBodyNode{
                //nodeB.position = positionB
                if !self.scene.isHost{
                    nodeB.physicsBody!.velocity = CGVectorMake(velocityB.dx * dampingFactor, velocityB.dy * dampingFactor)
                }
                else{
                    nodeB.physicsBody!.velocity = velocityB
                }
            }
        })
    }
    func receiveVelocities(manager: ConnectionManager, velocities:[String]){
        NSOperationQueue.mainQueue().addOperationWithBlock{
            let ballVelocity = CGVectorMake(-velocities[0].toFloat()*self.scaleFactorX*dampingFactor, velocities[1].toFloat()*self.scaleFactorY*dampingFactor)
            self.scene.ball.physicsBody!.velocity = ballVelocity
            var i = 2
            while i < velocities.count{
                let velocity = CGVectorMake(-velocities[i].toFloat()*self.scaleFactorX*dampingFactor, velocities[i+1].toFloat()*self.scaleFactorY*dampingFactor)
                self.scene.players[self.convertToIndex(i)].physicsBody!.velocity = velocity
                i+=2
            }
        }
    }

    func receiveStart(manager: ConnectionManager, settings:[String]){
        dispatch_async(dispatch_get_main_queue(),{
            self.connectedDevice = self.gameService.connectedDevice!.first?.displayName
            print("receiveStart")
            self.scene.isHost = true
            if settings.first! != "joined"{
                self.scene.isHost = false
                self.scene.mode = stringMode[settings.first!]!
            }
            self.scene.countryB = settings[1]
            self.scaleFactorX = screenWidth/settings[2].toFloat()
            self.scaleFactorY = screenHeight/settings[3].toFloat()
            if !self.sentData{
                self.gameService.sendStart(modeString[self.scene.mode]!,flag: self.scene.countryA)
                self.sentData = true
            }
            self.moveToScene()
        })
    }
    func receiveSync(manager: ConnectionManager, turn: String, gameTime: String){
        if turn.toBool()!{
            if scene.turnA{
                scene.switchTurns()
            }else{
                scene.moveTimer?.restart()
            }
        }else{
            if !scene.turnA{
                scene.switchTurns()
            }else{
                scene.moveTimer?.restart()
            }
        }
        if scene.mode.getType() == .timed{
            scene.gameTime = NSTimeInterval(gameTime.toFloat())
        }
    }
    func receiveMove(manager: ConnectionManager, move: [String]) {
        print("receiveMove")
        dispatch_async(dispatch_get_main_queue(), {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                let playerName = self.convertTeams(move[0])
                let velocityX = move[1].toFloat()
                let velocityY = move[2].toFloat()
                let position = CGPointMake(screenWidth-move[3].toFloat()*self.scaleFactorX, move[4].toFloat()*self.scaleFactorY)
                for player in self.scene.teamB{
                    if playerName == player.name{
                        if self.scene.isHost{
                            player.physicsBody!.velocity = CGVectorMake(-velocityX*self.scaleFactorX, velocityY*self.scaleFactorY)
                        }else{
                            player.physicsBody!.velocity = CGVectorMake(-velocityX*self.scaleFactorX*dampingFactor, velocityY*self.scaleFactorY*dampingFactor)
                        }
                        player.position = position
                        self.scene.switchTurns()
                        break
                    }
                }
            }
        })
    }
    func receivePositions(manager: ConnectionManager, positions: [String]){
        //print(dampingFactor)
        NSOperationQueue.mainQueue().addOperationWithBlock{
            let ballPosition = CGPointMake(screenWidth - positions[0].toFloat()*self.scaleFactorX, positions[1].toFloat()*self.scaleFactorY)
//            if self.scene.ball.physicsBody!.velocity.dx < 0{
//                if self.scene.ball.position.x < ballPosition.x-2{
//                    dampingFactor -= 0.01
//                }else if self.scene.ball.position.x > ballPosition.x+2{
//                    dampingFactor += 0.01
//                }
//            }
//            else{
//                if self.scene.ball.position.x > ballPosition.x+2{
//                    dampingFactor -= 0.01
//                }else if self.scene.ball.position.x < ballPosition.x-2{
//                    dampingFactor += 0.01
//                }
//            }
            self.scene.ball.position = ballPosition
            var i = 2
            while i < positions.count{
                let point = CGPointMake(screenWidth - positions[i].toFloat()*self.scaleFactorX, positions[i+1].toFloat()*self.scaleFactorY)
                self.scene.players[self.convertToIndex(i)].position = point
                i+=2
            }
        }
    }
    func receiveLoad(manager:ConnectionManager, load: [String]){
        print("loading")
        let position = CGPointMake(load[0].toFloat()*scaleFactorX, load[1].toFloat()*scaleFactorY)
        let velocity = CGVectorMake(load[2].toFloat()*scaleFactorX, load[3].toFloat()*scaleFactorY)
        if velocity.dx > 0{
            if position.x > self.scene.loadNode.position.x + 0.1{
                dampingFactor += 0.01
            }else if position.x < self.scene.loadNode.position.x - 0.1{
                dampingFactor -= 0.01
            }else{
                gameService.stringSend("tag loaded")
                scene.restart()
                scene.loaded = true
                scene.loadNode.removeFromParent()
                scene.userInteractionEnabled = true
                scene.viewController.Dimmer?.fadeOut(0.5)
                scene.viewController.loadingView.fadeOut(0.5)
                print(dampingFactor)
                print("RECEIVE LOADED")
            }
        }else if velocity.dx < 0{
            if position.x < self.scene.loadNode.position.x - 0.1{
                dampingFactor += 0.01
            }
            else if position.x > self.scene.loadNode.position.x + 0.1{
                dampingFactor -= 0.01
            }
            else{
                gameService.stringSend("tag loaded")
                scene.restart()
                scene.loaded = true
                scene.viewController.Dimmer?.fadeOut(0.5)
                self.scene.viewController.loadingView.fadeOut(0.5)
                scene.loadNode.removeFromParent()
                scene.userInteractionEnabled = true
                print(dampingFactor)
                print("RECEIVE LOADED")
            }
        }
        scene.loadNode.position = position
        scene.loadNode.physicsBody!.velocity = CGVectorMake(velocity.dx*dampingFactor, velocity.dy*dampingFactor)
        
    }

    func convertToIndex(index: Int) -> Int{
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
    func convertTeams(player:String)->String{
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
        let gameVC = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        gameVC.scene = scene
        gameVC.parent = self
        scene.viewController = gameVC
        scene.loaded = false
        scene.gType = .twoPhone
        gameService.getServiceBrowser().stopBrowsingForPeers()
        gameService.getServiceAdvertiser().stopAdvertisingPeer()
        self.navigationController!.pushViewController(gameVC, animated: true)
        JoinGame.userInteractionEnabled = true
        JoinGame.alpha = 1
    }
}
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
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


