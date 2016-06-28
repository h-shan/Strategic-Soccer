//
//  PauseViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/27/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    var parent:TitleViewController!
    var scene: GameScene!
    @IBAction func Quit(sender: AnyObject) {
        parent.PauseView.hidden = true
        scene.goBackToTitle()
        
    }
    @IBAction func Restart(sender: AnyObject) {
        parent.PauseView.hidden = true
        scene.paused = false
        scene.restart()
    }
    @IBAction func Resume(sender: AnyObject) {
        scene.paused = false
        parent.PauseView.hidden = true
        scene.moveTimer?.start()
        if scene.mode == Mode.threeMinute{
            scene.gameTimer.start()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        scene = parent.scene
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
