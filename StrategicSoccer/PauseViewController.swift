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
    var action: pauseAction = .restart
    
    @IBOutlet weak var Quit: UIButton!
    @IBOutlet weak var Restart: UIButton!
    @IBOutlet weak var Resume: UIButton!
    @IBAction func Quit(sender: AnyObject) {
        if scene.gType == .onePlayer{
            parent.PauseView.userInteractionEnabled = false
            parent.QuitWarningText.text = "ARE YOU SURE YOU WANT TO QUIT? THIS WILL COUNT AS A LOSS IN YOUR STATISTICS."
            parent.QuitWarningView.hidden = false
            action = .quit
        }else{
            pauseQuit()
        }
        
    }
    @IBAction func Restart(sender: AnyObject) {
        if scene.gType == .onePlayer{
            parent.PauseView.userInteractionEnabled = false
            parent.QuitWarningText.text = "ARE YOU SURE YOU WANT TO RESTART? THIS WILL COUNT AS A LOSS IN YOUR STATISTICS."
            parent.QuitWarningView.hidden = false
            action = .restart
        }
        else{
            pauseRestart()
        }
    }
    @IBAction func Resume(sender: AnyObject) {
        if scene.gType == .twoPhone && !parent.parent.sentPauseAction{
            parent.parent.gameService.sendPause("resume")
        }
        parent.parent.sentPauseAction = true
        self.parent.Dimmer?.fadeOut(0.2)
        parent.parent.sentPause = false

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
    func pauseRestart(){
        if scene.gType == gameType.twoPhone && !parent.parent.sentPauseAction{
            parent.parent.gameService.sendPause("restart")
        }
        parent.parent.sentPauseAction = true
        parent.parent.sentPause = false
        self.parent.Dimmer?.fadeOut(0.2)
        
        scene = parent.scene
        scene.physicsWorld.speed = 1
        parent.PauseView.hidden = true
        scene.paused = false
        scene.restart()
        scene.userInteractionEnabled = true
        scene.firstTurn = true
        scene.isSynced = false
    }
    func pauseQuit(){
        if scene.gType == .twoPhone && !parent.parent.sentPauseAction{
            parent.parent.gameService.sendPause("quit")
        }
        parent.parent.sentPauseAction = true
        parent.parent.sentPause = false
        scene = parent.scene
        parent.PauseView.hidden = true
        scene.goBackToTitle()
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
