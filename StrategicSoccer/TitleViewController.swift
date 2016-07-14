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
    var background = SKScene()
    var scene: GameScene!
    
    @IBOutlet weak var TwoPlayers: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var StrategicSoccer: UILabel!
    @IBOutlet weak var ChangePlayersButton: UIButton!
    @IBOutlet weak var SinglePlayer: UIButton!
    
    var skView: SKView!
    var defaultMode = Mode.threeMinute
    var defaultPlayers = PlayerOption.three
    
    var playerA = "Afghanistan"
    var playerB = "Albania"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let playA = defaults.objectForKey("PlayerA"){
            playerA = playA as! String
            playerB = defaults.objectForKey("PlayerB") as! String
        }
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene = GameScene(size: skView.bounds.size)
        SettingsButton.layer.cornerRadius = 10
        TwoPlayers.layer.cornerRadius = 10
        ChangePlayersButton.layer.cornerRadius = 10
        SinglePlayer.layer.cornerRadius = 10
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool){
        
        super.viewWillAppear(animated)
        
        let image = SKSpriteNode(imageNamed: "SoccerBackground2")
        background.addChild(image)
        image.position = CGPointMake(background.frame.midX, background.frame.midY)
        image.size = CGSizeMake(1,1)
        
        skView.presentScene(background)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
       
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TwoPlayerSegue"{
            let destinationVC = segue.destinationViewController as! GameViewController
            scene.mode = defaultMode
            scene.playerOption = defaultPlayers
            scene.countryA = playerA
            scene.countryB = playerB
            destinationVC.scene = scene
            destinationVC.parent = self
            scene.singlePlayer = false
        }
        if segue.identifier == "SettingsSegue"{
            let destinationVC = segue.destinationViewController as! SettingsViewController
            destinationVC.defaultMode = self.defaultMode
            destinationVC.defaultPlayers = defaultPlayers
            destinationVC.parent = self
        }
        if segue.identifier == "ChangePlayersSegue"{
            let destinationVC = segue.destinationViewController as! ChangePlayerViewController
            destinationVC.parent = self
            destinationVC.defaultA = playerA
            destinationVC.defaultB = playerB
        }
        if segue.identifier == "SinglePlayerSegue"{
            let destinationVC = segue.destinationViewController as! GameViewController
            scene.mode = defaultMode
            scene.playerOption = defaultPlayers
            scene.countryA = playerA
            scene.countryB = playerB
            destinationVC.scene = scene
            destinationVC.parent = self
            
            scene.cAggro = 0
            scene.cDef = 0
            scene.singlePlayer = true
        }
    }
}
