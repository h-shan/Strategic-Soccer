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
    }
    @IBAction func hideConnections(sender: AnyObject){
        ConnectionView.hidden = true
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
        self.JoinGame.userInteractionEnabled = true
        self.JoinGame.alpha = 1
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
    func receiveScreenSize(manager: ConnectionManager, size: [String]) {
        scaleFactorX = screenSize.width/CGFloat((size[0] as NSString).doubleValue)
        scaleFactorY = screenSize.height/CGFloat((size[1] as NSString).doubleValue)
    }
    func receiveMove(manager: ConnectionManager, move: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let playerName = move[0]
            let velocityX = CGFloat((move[1] as NSString).doubleValue)
            let velocityY = CGFloat((move[2] as NSString).doubleValue)
            print(playerName)
            for player in self.scene.teamB{
                if playerName == player.name{
                    player.physicsBody!.velocity = CGVectorMake(-velocityX, -velocityY)
                    self.scene.switchTurns()
                    break
                }
            }
        }
    }
    func receivePositions(manager: ConnectionManager, positions: [String]){
        NSOperationQueue.mainQueue().addOperationWithBlock{
            let ballPosition = CGPointMake(CGFloat((positions[0] as NSString).doubleValue), CGFloat((positions[1] as NSString).doubleValue))
            self.scene.ball.position = ballPosition
            var i = 2
            while i < positions.count{
                let point = CGPointMake(CGFloat((positions[i] as NSString).doubleValue)*self.scaleFactorX, CGFloat((positions[i+1] as NSString).doubleValue)*self.scaleFactorY)
                self.scene.players[self.convertToIndex(i)].position = point
                i+=2
            }
        }
    }
    func convertToIndex(index: Int) -> Int{
        let rawIndex = index/2-1
        switch(scene.playerOption){
        case .three:
            if rawIndex <= 3{
                return rawIndex + 3
            }
            return rawIndex-3
        case .four:
            if rawIndex <= 4{
                return rawIndex+4
            }; return rawIndex-4
        }
    }
}

