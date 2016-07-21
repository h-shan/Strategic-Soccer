//
//  PauseViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/27/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    var parent:GameViewController!
    var scene: GameScene!
    
    @IBOutlet weak var Quit: UIButton!
    @IBOutlet weak var Restart: UIButton!
    @IBOutlet weak var Resume: UIButton!
    @IBAction func Quit(sender: AnyObject) {
        scene = parent.scene
        parent.PauseView.hidden = true
        scene.goBackToTitle()
        
    }
    @IBAction func Restart(sender: AnyObject) {
        UIView.animateWithDuration(0.2,animations:{
            self.parent.Dimmer.alpha = 0.0
        })
        scene = parent.scene
        scene.physicsWorld.speed = 1
        parent.PauseView.hidden = true
        scene.paused = false
        scene.restart()
        scene.userInteractionEnabled = true
        scene.firstTurn = true
    }
    @IBAction func Resume(sender: AnyObject) {
        UIView.animateWithDuration(0.5,animations:{
            self.parent.Dimmer.alpha = 0.0
        })
        parent.scene.physicsWorld.speed = 1
        scene = parent.scene
        parent.PauseView.hidden = true
        scene.paused = false
        scene.moveTimer?.start()
        if scene.mode.getType() == .timed && scene.goalDelay.elapsedTime == 0{
            scene.gameTimer.start()
        }
        if scene.goalDelay.getElapsedTime() > 0{
            scene.goalDelay.start()
        }
        scene.userInteractionEnabled = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Quit.layer.cornerRadius = 10
        Restart.layer.cornerRadius = 10
        Resume.layer.cornerRadius = 10
        self.view.layer.cornerRadius = 10
        self.view.layer.borderWidth = 5
        self.view.layer.borderColor = gold
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
