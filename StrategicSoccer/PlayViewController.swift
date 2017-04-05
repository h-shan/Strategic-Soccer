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
    var hostedGames = [[String: AnyObject]]()
    var otherScreenSize : CGRect!
    var scaleFactorX: CGFloat = 0
    var scaleFactorY: CGFloat = 0
    var parentVC: TitleViewController!
    var connectedDevice: String?
    var sentData = false
    var sentPause = false
    var sentPauseAction = false
    let id = UUID().uuidString
    var username = UIDevice.current.name
    
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
   
    // MARK: Overrided Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConnectToAnotherDevice.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackground()
        BackButtonWidth.constant = 80/568*screenWidth
        BackButtonHeight.constant = 60/568*screenWidth
        let buttons:[UIButton] = [SinglePlayer, TwoPlayers, ConnectToAnotherDevice, JoinGame, HostGame]
        formatMenuButtons(buttons)
        
        ConnectionView.isHidden = true
        ConnectionView.layer.borderWidth = 5
        ConnectionView.layer.borderColor = UIColor.black.cgColor
        JoinGame.alpha = 0.5
        JoinGame.isUserInteractionEnabled = false
        HostGame.isUserInteractionEnabled = true
        HostGame.alpha = 1
        scene.countryA = parentVC.playerA
        scene.countryB = parentVC.playerB
        scene.addPlayers()
        respondToSocket()

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
        case "TwoPhoneSegue" :
            scene.gType = .twoPhone
            break
        default: break
        }
    }
    
    // MARK: IBActions
    
    @IBAction func backButton(_ sender: AnyObject){
        _ = navigationController?.popViewController(animated: true)
        gameService.session.disconnect()
    }
    
    @IBAction func showConnections(_ sender: AnyObject){
        ConnectionView.isHidden = false
        HostGame.alpha = 1
        HostGame.isUserInteractionEnabled = true
    }
    
    @IBAction func hostGame(_ sender: AnyObject){
        //gameService.getServiceAdvertiser().startAdvertisingPeer()
        //gameService.getServiceBrowser().startBrowsingForPeers()
        self.gameTableView.reloadData()
        HostGame.isUserInteractionEnabled = false
        HostGame.alpha = 0.5
        scene.isHost = false
        connectToServer()
    }
    
    @IBAction func joinGame(_ sender: AnyObject){
        // rename to invite game, user who clicks join game will be host!
        sentData = true
        JoinGame.alpha = 0.5
        JoinGame.isUserInteractionEnabled = false
        SocketIOManager.sharedInstance.connectGame(self.username, otherUsername: connectedDevice!) { (opponentName, host) in
            self.scene.isHost = host
            print("connect game update")
            if host {
                SocketIOManager.sharedInstance.sendGameInfo(self.username, mode: modeString[self.scene.mode]!, flag: self.scene.countryA, screenWidth: screenWidth, screenHeight: screenHeight, friction: defaultFriction)
            }
        }
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
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connectedDevice = self.hostedGames[indexPath.row]["username"] as? String
        self.JoinGame.alpha = 1
        self.JoinGame.isUserInteractionEnabled = true
        //gameService.connectToDevice(connectedDevice!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = hostedGames[indexPath.row]["username"] as? String
        if (cell.textLabel?.text! == self.username) {
            cell.isUserInteractionEnabled = false
            cell.alpha = 0.5
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostedGames.count
    }
    
    // MARK: Custom Methods
    func connectToServer() {
        SocketIOManager.sharedInstance.connectToServerWithUsername(self.username, completionHandler: { (userList) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Updated user list")
                if userList != nil {
                    self.hostedGames = userList!
                    self.gameTableView.reloadData()
                }
            })
        })
    }
}

// MARK: SocketManager functions

extension PlayViewController {
    func respondToSocket() {
        
        // game info update
        SocketIOManager.sharedInstance.socket.on("gameInfoUpdate") { (settings, ack) -> Void in
            print("game info update")
            if !self.scene.isHost{
                // if not host, then update scene paramaters
                self.scene.mode = stringMode[settings[0] as! String]!
                self.scene.gameTimer.restart()
                defaultFriction = settings[4] as! Float
                SocketIOManager.sharedInstance.sendGameInfo(self.username, mode: modeString[self.scene.mode]!, flag: self.scene.countryA, screenWidth: screenWidth, screenHeight: screenHeight, friction: defaultFriction)
            }
            // general configurations
            let opponentFlag = settings[1] as! String
            if self.scene.countryB != opponentFlag {
                self.scene.countryB = opponentFlag
                self.scene.playersAdded = false
            }
            self.scaleFactorX = screenWidth/(settings[2] as! CGFloat)
            self.scaleFactorY = screenHeight/(settings[3] as! CGFloat)
            self.moveToScene()
            self.timer.restart()
        }
    }
}




