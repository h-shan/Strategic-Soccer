//
//  GameViewController.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright (c) 2016 HS. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var parent: TitleViewController!
    @IBOutlet weak var PauseView: UIView!
    
    @IBAction func PauseClicked(sender: AnyObject) {
        PauseView.hidden = false
        
        scene.moveTimer!.pause()
        if scene.mode == Mode.threeMinute{
            scene.gameTimer.pause()
        }
        scene.goalDelay.pause()
        scene.paused = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scene.viewController = self
        // Configure the view.
        let skView = self.view as! SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        PauseView.hidden = true
        skView.presentScene(scene)
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
            let destinationVC = segue.destinationViewController as! PauseViewController
            destinationVC.parent = self
        }
    }
    func backToTitle(){
        parent.scene = GameScene(size: parent.skView.bounds.size)
        navigationController?.popViewControllerAnimated(false)
        
    }
}
