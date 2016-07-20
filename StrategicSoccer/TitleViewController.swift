//
//  TitleViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/26/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
import SpriteKit
let defaults = NSUserDefaults.standardUserDefaults()
let modeKey = "Mode"
let playerAKey = "PlayerA"
let playerBKey = "PlayerB"
let playerOptionKey = "PlayerOption"
let AIKey = "AIDifficulty"
let gold = UIColor(red: 161/255.0, green: 155/255.0, blue: 75/255.0, alpha: 1.0).CGColor
let optima = UIFont(name: "Optima", size: 18)
let screenSize: CGRect = UIScreen.mainScreen().bounds
let scalerX = screenSize.width/1136
let scalerY = screenSize.height/640
let goalLineB = 1086*scalerX
let goalLineA = 50*scalerX
var coins = 50
var statistics = [Stats.totalGames:0,Stats.totalWon:0,Stats.totalOne:0,Stats.oneWon:0,Stats.totalTwo:0,Stats.twoWon: 0, Stats.totalThree:0,Stats.threeWon:0,Stats.totalFour:0,Stats.fourWon:0,Stats.totalFive:0,Stats.fiveWon:0]

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
    
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var StrategicSoccer: UILabel!
    @IBOutlet weak var ChangePlayersButton: UIButton!
    @IBOutlet weak var StatsButton: UIButton!
    @IBOutlet weak var NumberCoins: UILabel!
    var skView: SKView!
    var defaultMode = Mode.threeMinute
    var defaultPlayers = PlayerOption.three
    var defaultAI = 0
    var unlockedFlags:[String]!
    
    var playerA = "AFGHANISTAN"
    var playerB = "ALBANIA"
    
    override func viewDidLoad() {
        UIView.setAnimationsEnabled(true)
        super.viewDidLoad()
        if let playA = defaults.objectForKey(playerAKey){
            playerA = playA as! String
            playerA = playerA.uppercaseString
            playerB = defaults.objectForKey(playerBKey) as! String
            playerB = playerB.uppercaseString
        }
        if let storedMode = defaults.objectForKey(modeKey){
            defaultMode = Mode(rawValue: storedMode as! Int)!
        }
        if let storedPlayers = defaults.objectForKey(playerOptionKey){
            defaultPlayers = PlayerOption(rawValue: storedPlayers as! Int)!
        }
        if let AIDifficulty = defaults.objectForKey(AIKey){
            defaultAI = AIDifficulty as! Int
        }
        if let numCoins = NSKeyedUnarchiver.unarchiveObjectWithFile(Unlockable.CoinURL.path!) as? Int{
           coins = numCoins
        }
        if let storedStats = NSKeyedUnarchiver.unarchiveObjectWithFile(Unlockable.StatsURl.path!) as? [String:Int]{
            statistics = storedStats
        }
        // bring out unlocked
        if let storedUnlock = NSKeyedUnarchiver.unarchiveObjectWithFile(Unlockable.FlagURL.path!) as? [String]{
            unlockedFlags = storedUnlock
        }
        else{
            unlockedFlags = Unlockable().unlockedFlags
        }
        
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene = GameScene(size: skView.bounds.size)
        let buttons: [UIButton] = [SettingsButton, PlayButton, ChangePlayersButton, StatsButton]
        formatMenuButtons(buttons)

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
        addCoinImage("", afterText: String(coins), label: NumberCoins, numberLines: 1)
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "PlaySegue"{
            let destinationVC = segue.destinationViewController as! PlayViewController
            scene.mode = defaultMode
            scene.playerOption = defaultPlayers
            scene.countryA = playerA
            scene.countryB = playerB
            scene.AIDifficulty = defaultAI
            destinationVC.scene = scene
            destinationVC.parent = self
            scene.addPlayers()
            scene.cAggro = 0
            scene.cDef = 0
        }
        if segue.identifier == "SettingsSegue"{
            let destinationVC = segue.destinationViewController as! SettingsViewController
            destinationVC.defaultMode = self.defaultMode
            destinationVC.defaultPlayers = defaultPlayers
            destinationVC.defaultAI = defaultAI
            destinationVC.parent = self
        }
        if segue.identifier == "ChangePlayersSegue"{
            let destinationVC = segue.destinationViewController as! ChangePlayerViewController
            destinationVC.parent = self
            destinationVC.defaultA = playerA
            destinationVC.defaultB = playerB
            destinationVC.unlockedFlags = unlockedFlags
        }
        
    }
}

func addCoinImage(beforeText: String, afterText: String, label: UILabel, numberLines: Int){
    let coinImage = UIImage(named:"Coins")!
    let scaleSize = CGSizeMake(0.8*label.frame.height*coinImage.size.width/coinImage.size.height/CGFloat(numberLines),0.8*label.frame.height/CGFloat(numberLines))
    UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0)
    coinImage.drawInRect(CGRectMake(0, 0, scaleSize.width, scaleSize.height))
    let resizedCoins = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let stackOfCoins = NSTextAttachment()
    stackOfCoins.image = resizedCoins
    let attachmentString = NSAttributedString(attachment: stackOfCoins)
    let coinString = NSMutableAttributedString(string: beforeText)
    coinString.appendAttributedString(attachmentString)
    coinString.appendAttributedString(NSAttributedString(string: " " + afterText))
    label.attributedText = coinString
}
func formatMenuButtons(buttons: [UIButton]){
    for button in buttons{
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = gold
    }
}
