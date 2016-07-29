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
    var parent: PlayViewController!
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
    
    @IBAction func PauseClicked(sender: AnyObject) {
        if scene.gType == .twoPhone && !parent.sentPause{
            parent.gameService.sendPause("pause")
        }
        parent.sentPauseAction = false
        parent.sentPause = true
        PauseView.hidden = false
        scene.moveTimer!.pause()
        if scene.mode.getType() == .timed{
            scene.gameTimer.pause()
        }
        scene.goalDelay.pause()
        scene.userInteractionEnabled = false
        scene.paused = true
        UIView.animateWithDuration(0.2,animations:{
            self.Dimmer?.alpha = 0.5
        })
    }
    @IBAction func YesQuit(sender: AnyObject){
        QuitWarningView.hidden = true
        PauseView.userInteractionEnabled = true
        switch(pauseVC.action){
        case .quit:
            pauseVC.pauseQuit()
            break
        case .restart:
            pauseVC.pauseRestart()
        }
    }
    @IBAction func NoQuit(sender: AnyObject){
        PauseView.userInteractionEnabled = true
        QuitWarningView.hidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.layer.borderWidth = 5
        loadingView.layer.borderColor = UIColor.blackColor().CGColor
        QuitWarningView.layer.borderWidth = 5
        QuitWarningView.layer.borderColor = UIColor.blackColor().CGColor
        scene.viewController = self
        
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .AspectFill
        PauseView.hidden = true
        NumberCoins.alpha = 0.0
        scene.userInteractionEnabled = false
        QuitWarningView.hidden = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if scene.gType != .twoPhone{
            self.Dimmer?.fadeOut(1.0)
            scene.userInteractionEnabled = true
        }
    }
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        skView.presentScene(scene)
        self.Dimmer?.alpha = 0.8
        if scene.gType != .twoPhone{
            loadingView.alpha = 0
        }else{
            loadingView.alpha = 0.9
        }
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Pause"{
            pauseVC = segue.destinationViewController as! PauseViewController
            pauseVC.parent = self
            pauseVC.scene = scene
        }
    }
    func backToTitle(){
        navigationController?.popViewControllerAnimated(false)

        self.removeFromParentViewController()
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapShot = UIImageView(image: image)
        view.addSubview(snapShot)
        skView.presentScene(nil)
        skView.removeFromSuperview()
        snapShot.removeFromSuperview()
        view = nil
        parent.sentData = false
        parent.sentPause = false
        scene.isSynced = false
        scene.loaded = false
        print("GameViewController backToTitle")
    
    }
    func displayEarnings(numberWon: Int){
        addCoinImage("YOU WON ", afterText: String(numberWon), label: NumberCoins, numberLines: 1)
        UIView.animateWithDuration(1,delay:0.3,options: .CurveEaseIn, animations: {
            self.NumberCoins.alpha = CGFloat(1.0)
            },completion: nil)
        coins += numberWon
        saveCoins()
    }
}
extension UIView{
    func fadeOut(time:Double){
        UIView.animateWithDuration(time, animations: {
            self.alpha = 0
        })
    }
    func fadeIn(time: Double){
        UIView.animateWithDuration(time, animations: {
            self.alpha = 0.8;
        })
    }
}
    

