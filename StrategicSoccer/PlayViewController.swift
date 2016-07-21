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
    var parent: TitleViewController!
    @IBOutlet weak var SinglePlayer: UIButton!
    @IBOutlet weak var TwoPlayers: UIButton!
    @IBOutlet weak var ConnectToAnotherDevice: UIButton!
    @IBOutlet weak var ConnectionView: UIView!
    @IBAction func backButton(sender: AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        gameService.delegate = self
        setBackground()
        let buttons:[UIButton] = [SinglePlayer, TwoPlayers, ConnectToAnotherDevice]
        formatMenuButtons(buttons)
        ConnectionView.hidden = true
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
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
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
        }
    }
    
    func receiveMove(manager: ConnectionManager, move: [String]) {
        print("Did call receiveMove")
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let playerName = move[0]
            let velocityX = CGFloat((move[1] as NSString).doubleValue)
            let velocityY = CGFloat((move[2] as NSString).doubleValue)
            print(playerName)
            for player in self.scene.teamB{
                if playerName == player.name{
                    player.physicsBody!.velocity = CGVectorMake(-velocityX, -velocityY)
                    self.scene.switchTurns()
                    print("Did change velocity")
                    break
                }
            }
        }
    }
}

