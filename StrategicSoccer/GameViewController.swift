//
//  GameViewController.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright (c) 2016 HS. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    var scene: GameScene!
    var parentVC: PlayViewController!
    var pauseVC: PauseViewController!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var PauseView: UIView!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var NumberCoins: UILabel!
    @IBOutlet weak var Dimmer: UIView?
    @IBOutlet weak var QuitWarningView: UIView!
    @IBOutlet weak var QuitWarningText: UILabel!
    @IBOutlet weak var YesQuit: UIButton!
    @IBOutlet weak var NoQuit: UIButton!
    
    @IBAction func PauseClicked(_ sender: AnyObject) {
        if scene.gType == .twoPhone && !parentVC.sentPause{
            parentVC.gameService.sendPause("pause")
        }
        parentVC.sentPauseAction = false
        parentVC.sentPause = true
        PauseView.isHidden = false
        scene.moveTimer!.pause()
        if scene.mode.getType() == .timed{
            scene.gameTimer.pause()
        }
        scene.goalDelay.pause()
        scene.isUserInteractionEnabled = false
        scene.isPaused = true
        UIView.animate(withDuration: 0.2,animations:{
            self.Dimmer?.alpha = 0.5
        })
    }
    @IBAction func YesQuit(_ sender: AnyObject){
        QuitWarningView.isHidden = true
        PauseView.isUserInteractionEnabled = true
        scene.updateStats(false)
        switch(pauseVC.action){
        case .quit:
            pauseVC.pauseQuit()
            break
        case .restart:
            pauseVC.pauseRestart()
        }
    }
    @IBAction func NoQuit(_ sender: AnyObject){
        PauseView.isUserInteractionEnabled = true
        QuitWarningView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.layer.borderWidth = 5
        loadingView.layer.borderColor = UIColor.black.cgColor
        scene.viewController = self
        NumberCoins.layer.borderWidth = 0
        NumberCoins.layer.borderColor = UIColor.black.cgColor
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
        PauseView.isHidden = true
        NumberCoins.alpha = 0.0
        scene.isUserInteractionEnabled = false
        QuitWarningView.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if scene.gType != .twoPhone{
            self.Dimmer?.fadeOut(1.0)
            scene.isUserInteractionEnabled = true
        }
    }
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        skView.presentScene(scene)
//        let penaltyScene = PenaltyScene(gameScene: scene)
//        skView.presentScene(penaltyScene)
        self.Dimmer?.alpha = 0.8
        if scene.gType != .twoPhone{
            loadingView.alpha = 0
        }else{
            loadingView.alpha = 0.9
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Pause"{
            pauseVC = segue.destination as! PauseViewController
            pauseVC.parentVC = self
            pauseVC.scene = scene
        }
    }
    func backToTitle(){
        _ = navigationController?.popViewController(animated: false)

        self.removeFromParentViewController()
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapShot = UIImageView(image: image)
        view.addSubview(snapShot)
        skView.presentScene(nil)
        skView.removeFromSuperview()
        snapShot.removeFromSuperview()
        view = nil
        parentVC.sentData = false
        parentVC.sentPause = false
        scene.isSynced = false
        scene.loaded = true
    }
    
    func displayEarnings(_ numberWon: Int){
        addCoinImage("YOU WON ", afterText: String(numberWon), label: NumberCoins, numberLines: 1)
        UIView.animate(withDuration: 1,delay:0.3,options: .curveEaseIn, animations: {
            self.NumberCoins.alpha = CGFloat(1.0)
            },completion: nil)
        coins += numberWon
        saveCoins()
    }
}
extension UIView{
    func fadeOut(_ time:Double){
        UIView.animate(withDuration: time, animations: {
            self.alpha = 0
        })
    }
    func fadeIn(_ time: Double){
        UIView.animate(withDuration: time, animations: {
            self.alpha = 0.8;
        })
    }
}
    

