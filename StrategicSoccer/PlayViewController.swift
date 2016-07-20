//
//  PlayViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/20/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
class PlayViewController: UIViewController{
    var scene: GameScene!
    var parent: TitleViewController!
    @IBOutlet weak var SinglePlayer: UIButton!
    @IBOutlet weak var TwoPlayers: UIButton!
    @IBAction func backButton(sender: AnyObject){
        navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        let buttons:[UIButton] = [SinglePlayer, TwoPlayers]
        formatMenuButtons(buttons)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! GameViewController
        
        destinationVC.scene = scene
        destinationVC.parent = self
        switch(segue.identifier!){
        case "TwoPlayersSegue":
            scene.singlePlayer = false
            break
        case "SinglePlayerSegue":
            scene.singlePlayer = true
            break
        default: break
        }
    }
}
