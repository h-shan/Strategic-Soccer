//
//  TitleViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/26/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
import SpriteKit
extension UIViewController{
    func setBackground(){
        let background = UIImage(named: "SoccerBackground2")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
   
}
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
        let buttons: [UIButton] = [SettingsButton, TwoPlayers,ChangePlayersButton,SinglePlayer]
        for button in buttons{
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(red: 0.631, green: 0.608, blue: 0.294, alpha: 1.0).CGColor
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool){
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
        setBackground()
       
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
