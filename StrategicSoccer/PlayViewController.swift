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
    var opponent = ""
    var playerDict: [String: String]!
    var movedToScene = false
    
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
        respondToSocket()
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
        SocketIOManager.sharedInstance.establishConnection()

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
        JoinGame.alpha = 0.5
        JoinGame.isUserInteractionEnabled = false
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
        gameTableView.deselectRow(at: gameTableView.indexPathForSelectedRow!, animated: false)
        SocketIOManager.sharedInstance.connectGame(self.username, otherUsername: opponent)
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
        opponent = self.hostedGames[indexPath.row]["username"] as! String
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
        SocketIOManager.sharedInstance.socket.on("gameInfoUpdate") { (settings, ack) in
            print("game info update")
            if !self.scene.isHost{
                // if not host, then update scene paramaters
                self.scene.mode = stringMode[settings[0] as! String]!
                self.scene.playerOption = intToPOption[settings[1] as! Int]!
                self.scene.gameTimer.restart()
                defaultFriction = settings[5] as! Float
                
                if self.scene.playerOption == PlayerOption.three {
                    self.playerDict = player3Dict
                } else {
                    self.playerDict = player4Dict
                }
                SocketIOManager.sharedInstance.sendGameInfo(self.opponent, mode: modeString[self.scene.mode]!, playerOption: self.scene.playerOption, flag: self.scene.countryA, screenWidth: screenWidth, screenHeight: screenHeight, friction: defaultFriction)
            }
            
            // general configurations
            let opponentFlag = settings[2] as! String
            if self.scene.countryB != opponentFlag {
                self.scene.countryB = opponentFlag
                self.scene.playersAdded = false
            }
            self.scaleFactorX = screenWidth/(settings[3] as! CGFloat)
            self.scaleFactorY = screenHeight/(settings[4] as! CGFloat)
            self.movedToScene = true
            self.moveToScene()
            self.timer.restart()
        }
        
        SocketIOManager.sharedInstance.socket.on("pauseUpdate") { (pauseOption, ack) in
            let pOption = pauseOption[0] as! String
            print ("pause \(pOption)")
            switch pOption {
            case Pause.pause:
                self.scene.viewController.PauseClicked(self)
                break
            case Pause.resume:
                self.scene.viewController.pauseVC.Resume(self)
                break
            case Pause.restart:
                self.scene.viewController.pauseVC.Restart(self)
                break
            case Pause.quit:
                self.scene.viewController.pauseVC.Quit(self)
                break
            default:
                break
            }
        }
        
        SocketIOManager.sharedInstance.socket.on("connectGameUpdate") { (opp, ack) in
            print ("connect game update")
            let opponentName = opp[0] as! String
            let isHost = opp[1] as! Bool
            self.scene.isHost = isHost
            self.opponent = opponentName
            if self.scene.playerOption == PlayerOption.three {
               self.playerDict = player3Dict
            } else if self.scene.playerOption == PlayerOption.four {
                self.playerDict = player4Dict
            }
            if isHost {
                SocketIOManager.sharedInstance.sendGameInfo(opponentName, mode: modeString[self.scene.mode]!, playerOption: self.scene.playerOption, flag: self.scene.countryA, screenWidth: screenWidth, screenHeight: screenHeight, friction: defaultFriction)
            }
        }
        
        SocketIOManager.sharedInstance.socket.on("moveUpdate") { (moveInfo, ack) in
            //print("move update")
            let playerName = self.playerDict[moveInfo[0] as! String]!
            let velX = -(moveInfo[1] as! CGFloat) * self.scaleFactorX
            let velY = -(moveInfo[2] as! CGFloat) * self.scaleFactorY
            let player = self.scene.nameToPlayer[playerName]!
            player.unHighlight()
            player.changeColorBright()
            self.scene.updateLighting()
            player.physicsBody!.velocity = CGVector(dx: velX, dy: velY)
            if !self.scene.turnA {
                self.scene.switchTurns()
            } else {
                self.scene.moveTimer!.restart()
            }
        
        }
        
        SocketIOManager.sharedInstance.socket.on("positionVelocityUpdate") { (posVelInfo, ack) in
            //print("positionVelocityUpdate")
            let posVelDict = posVelInfo[0] as! [String:[CGFloat]]
            let sendTime = posVelInfo[1] as! TimeInterval
            var lagTime = CGFloat(Date.timeIntervalSinceReferenceDate - sendTime)
            if lagTime > 0.5 {
                print(lagTime)
                return
            }
            lagTime *= 0.5
            for posVel in posVelDict {
                if posVel.key == "ball" {
                    continue
                }
                let pName = self.playerDict[posVel.key]!
                let info = posVel.value
                var pPosition = CGPoint(x: screenWidth - info[0] * self.scaleFactorX, y: screenHeight-info[1] * self.scaleFactorY)
                let pVelocity = CGVector(dx: -info[2] * self.scaleFactorX, dy: -info[3] * self.scaleFactorY)
                let player = self.scene.nameToPlayer[pName]!
                
                // account for lag
                pPosition.x += pVelocity.dx * lagTime
                pPosition.y += pVelocity.dy * lagTime
                let currentPosition = player.position
                // to smooth transition, take one third point to end
                pPosition.x = (pPosition.x + currentPosition.x * 2) / 3
                pPosition.y = (pPosition.y + currentPosition.y * 2) / 3
                player.position = pPosition
                player.physicsBody!.velocity = pVelocity
            }
            let ballInfo = posVelDict["ball"]!
            
            var bPosition = CGPoint(x: screenWidth - ballInfo[0] * self.scaleFactorX, y: screenHeight - ballInfo[1] * self.scaleFactorY)
            
            let bVelocity = CGVector(dx: -ballInfo[2] * self.scaleFactorX, dy: -ballInfo[3] * self.scaleFactorY)
            bPosition.x += bVelocity.dx * lagTime
            bPosition.y += bVelocity.dy * lagTime
            let currentBallPosition = self.scene.ball.position
            bPosition.x = (bPosition.x + currentBallPosition.x * 2) / 3
            bPosition.y = (bPosition.y + currentBallPosition.y * 2) / 3
            self.scene.ball.position = bPosition
            self.scene.ball.physicsBody!.velocity = bVelocity
        }
    }
}




