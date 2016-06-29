//
//  TitleViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/26/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
import SpriteKit

class TitleViewController: UIViewController {
    let background = SKScene()
    var scene: GameScene!
    var skView: SKView!
    var defaultMode = Mode.threeMinute
    var defaultPlayers = PlayerOption.three


    @IBOutlet weak var StrategicSoccerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene = GameScene(size: skView.bounds.size)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool){
        
        super.viewWillAppear(animated)
        skView.presentScene(background)
        skView.scene!.backgroundColor = UIColor.greenColor()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
       
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GameSegue"{
            let destinationVC = segue.destinationViewController as! GameViewController
            destinationVC.scene = scene
            destinationVC.parent = self
        }
        if segue.identifier == "SettingsSegue"{
            let destinationVC = segue.destinationViewController as! SettingsViewController
            destinationVC.scene = scene
            destinationVC.defaultMode = defaultMode
            destinationVC.defaultPlayers = defaultPlayers
        }
    }



}
