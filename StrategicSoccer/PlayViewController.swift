//
//  PlayViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/20/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
class PlayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var scene: GameScene!
    let gameService = ConnectionManager()
    var hostedGames = [String]()
    var otherScreenSize : CGRect!
    var scaleFactorX: CGFloat!
    var scaleFactorY: CGFloat!
    var parent: TitleViewController!
    var connectedDevice: String?
    var sentData = false
    @IBOutlet weak var SinglePlayer: UIButton!
    @IBOutlet weak var TwoPlayers: UIButton!
    @IBOutlet weak var ConnectToAnotherDevice: UIButton!
    @IBOutlet weak var ConnectionView: UIView!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var JoinGame: UIButton!
    @IBOutlet weak var HostGame: UIButton!
    @IBAction func backButton(sender: AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func showConnections(sender: AnyObject){
        ConnectionView.hidden = false
    }
    @IBAction func hostGame(sender: AnyObject){
        gameService.getServiceAdvertiser().startAdvertisingPeer()
        
        self.gameTableView.reloadData()
        HostGame.userInteractionEnabled = false
        HostGame.alpha = 0.5
    }
    @IBAction func joinGame(sender: AnyObject){
        gameService.sendStart(nil, flag: scene.countryA)
        sentData = true
    }
    @IBAction func hideConnections(sender: AnyObject){
        ConnectionView.hidden = true
        gameService.getServiceAdvertiser().stopAdvertisingPeer()
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
        let buttons:[UIButton] = [SinglePlayer, TwoPlayers, ConnectToAnotherDevice, JoinGame, HostGame]
        formatMenuButtons(buttons)
        ConnectionView.hidden = true
        ConnectionView.layer.borderWidth = 5
        ConnectionView.layer.borderColor = UIColor.blackColor().CGColor
        JoinGame.alpha = 0.5
        JoinGame.userInteractionEnabled = false
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
        case "TwoPhoneSegue":
            scene.gType = .twoPhone
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
}
extension PlayViewController : ConnectionManagerDelegate {
    func connectedDevicesChanged(manager: ConnectionManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.hostedGames = connectedDevices
            self.gameTableView.reloadData()
        }
    }
    func receiveStart(manager: ConnectionManager, settings:[String]){
        
        connectedDevice = gameService.connectedDevice!.first?.displayName
        print("receiveStart")
        scene.isHost = true
        if settings.first! != "joined"{
            scene.isHost = false
            scene.isPuppet = true
            scene.mode = stringMode[settings.first!]!
        }
        scene.countryB = settings[1]
        scaleFactorX = screenSize.width/CGFloat((settings[2] as NSString).doubleValue)
        scaleFactorY = screenSize.height/CGFloat((settings[3] as NSString).doubleValue)
        moveToScene()
        if !sentData{
            gameService.sendStart(modeString[scene.mode]!,flag: scene.countryA)
            sentData = true
        }
    }
    func receiveMove(manager: ConnectionManager, move: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let playerName = move[0]
            let velocityX = CGFloat((move[1] as NSString).doubleValue)
            let velocityY = CGFloat((move[2] as NSString).doubleValue)
            for player in self.scene.teamB{
                if playerName == player.name{
                    if !self.scene.isPuppet{
                        player.physicsBody!.velocity = CGVectorMake(-velocityX, velocityY)
                    }
                    self.scene.switchTurns()
                    break
                }
            }
        }
    }
    func receivePositions(manager: ConnectionManager, positions: [String]){
        NSOperationQueue.mainQueue().addOperationWithBlock{
            let ballPosition = CGPointMake(self.view.frame.maxX - CGFloat((positions[0] as NSString).doubleValue)*self.scaleFactorX, CGFloat((positions[1] as NSString).doubleValue)*self.scaleFactorX)
            self.scene.ball.position = ballPosition
            var i = 2
            while i < positions.count{
                let point = CGPointMake(self.view.frame.maxX - CGFloat((positions[i] as NSString).doubleValue)*self.scaleFactorX, CGFloat((positions[i+1] as NSString).doubleValue)*self.scaleFactorY)
                self.scene.players[self.convertToIndex(i)].position = point
                i+=2
            }
        }
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
    func moveToScene(){
        let gameVC = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        gameVC.scene = scene
        gameVC.parent = self
        scene.gType = .twoPhone
        self.navigationController!.pushViewController(gameVC, animated: true)
    }
}

