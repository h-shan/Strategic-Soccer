//
//  PauseViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/27/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    var parentVC: GameViewController!
    var scene: GameScene!
    var action: pauseAction = .restart
    
    @IBOutlet weak var Quit: UIButton!
    @IBOutlet weak var Restart: UIButton!
    @IBOutlet weak var Resume: UIButton!
    @IBAction func Quit(_ sender: AnyObject) {
        if scene.gType == .onePlayer{
            parentVC.PauseView.isUserInteractionEnabled = false
            parentVC.QuitWarningText.text = "ARE YOU SURE YOU WANT TO QUIT? THIS WILL COUNT AS A LOSS IN YOUR STATISTICS."
            parentVC.QuitWarningView.isHidden = false
            action = .quit
        }else{
            pauseQuit()
        }
        
    }
    @IBAction func Restart(_ sender: AnyObject) {
        if scene.gType == .onePlayer{
            parentVC.PauseView.isUserInteractionEnabled = false
            parentVC.QuitWarningText.text = "ARE YOU SURE YOU WANT TO RESTART? THIS WILL COUNT AS A LOSS IN YOUR STATISTICS."
            parentVC.QuitWarningView.isHidden = false
            action = .restart
        }
        else{
            pauseRestart()
        }
    }
    @IBAction func Resume(_ sender: AnyObject) {
        if scene.gType == .twoPhone && !parentVC.parentVC.sentPauseAction{
            parentVC.parentVC.gameService.sendPause("resume")
        }
        parentVC.parentVC.sentPauseAction = true
        self.parentVC.Dimmer?.fadeOut(0.2)
        parentVC.parentVC.sentPause = false

        parentVC.scene.physicsWorld.speed = 1
        scene = parentVC.scene
        parentVC.PauseView.isHidden = true
        scene.isPaused = false
        scene.moveTimer?.start()
        if scene.mode.getType() == .timed && scene.goalDelay.elapsedTime == 0{
            scene.gameTimer.start()
        }
        if scene.goalDelay.getElapsedTime() > 0{
            scene.goalDelay.start()
        }
        scene.isUserInteractionEnabled = true
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
        if scene.gType == gameType.twoPhone && !parentVC.parentVC.sentPauseAction{
            parentVC.parentVC.gameService.sendPause("restart")
        }
        parentVC.parentVC.sentPauseAction = true
        parentVC.parentVC.sentPause = false
        self.parentVC.Dimmer?.fadeOut(0.2)
        scene = parentVC.scene
        scene.physicsWorld.speed = 1
        parentVC.PauseView.isHidden = true
        scene.isPaused = false
        scene.restart()
        scene.isUserInteractionEnabled = true
        scene.firstTurn = true
    }
    func pauseQuit(){
        if scene.gType == .twoPhone && !parentVC.parentVC.sentPauseAction{
            parentVC.parentVC.gameService.sendPause("quit")
        }
        parentVC.parentVC.sentPauseAction = true
        parentVC.parentVC.sentPause = false
        scene = parentVC.scene
        parentVC.PauseView.isHidden = true
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
