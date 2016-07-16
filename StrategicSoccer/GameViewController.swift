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
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var PauseButton: UIButton!
    @IBAction func PauseClicked(sender: AnyObject) {
        PauseView.hidden = false
        scene.moveTimer!.pause()
        if scene.mode.getType() == .timed{
            scene.gameTimer.pause()
        }
        scene.goalDelay.pause()
        scene.userInteractionEnabled = false
        scene.paused = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene.viewController = self
        
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        PauseView.hidden = true
        
    }
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        skView.presentScene(scene)
        skView.showsNodeCount = true

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
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
