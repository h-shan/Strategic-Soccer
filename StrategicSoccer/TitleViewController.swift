//
//  TitleViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/26/16.
//  Copyright © 2016 HS. All rights reserved.
//
var modeString = [Mode: String]()
var stringMode = [String:Mode]()
import UIKit
import SpriteKit
let defaults = UserDefaults.standard
let modeKey = "Mode"
let playerAKey = "PlayerA"
let playerBKey = "PlayerB"
let playerOptionKey = "PlayerOption"
let frictionKey = "Friction"
let AIKey = "AIDifficulty"
let playerSensitivityKey = "PlayerSensitivity"
let gold = UIColor(red: 161/255.0, green: 155/255.0, blue: 75/255.0, alpha: 1.0).cgColor
let optima = UIFont(name: "Optima", size: 18)
let screenSize: CGRect = UIScreen.main.bounds
var screenWidth:CGFloat = 0
var screenHeight:CGFloat = 0
var scalerX:CGFloat = 0
var scalerY:CGFloat = 0
let goalLineB = 1076*scalerX
let goalLineA = 60*scalerX
var coins = 50
var statistics = [Stats.totalGames:0,Stats.totalWon:0,Stats.totalOne:0,Stats.oneWon:0,Stats.totalTwo:0,Stats.twoWon: 0, Stats.totalThree:0,Stats.threeWon:0,Stats.totalFour:0,Stats.fourWon:0,Stats.totalFive:0,Stats.fiveWon:0]

extension UIViewController{
    func setBackground(){
        let background = UIImage(named: "SoccerBackground2")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
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
    @IBOutlet weak var CoinInfo: UILabel!
    
    @IBOutlet weak var ButtonWidth: NSLayoutConstraint!
    @IBAction func clickCoin(_ sender: AnyObject){
        UIView.animate(withDuration: 0.5, animations: {
            self.CoinInfo.alpha = 0.8
            _ = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.hideCoinInfo), userInfo: nil, repeats: false)
        })
    }
    var skView: SKView!
    var defaultMode = Mode.threeMinute
    var defaultPlayers = PlayerOption.three
    var defaultAI = 1
    var defaultFriction:Float = 1
    var defaultSensitivity: Float = 2
    var unlockedFlags:[String]!
    
    var playerA = "AUSTRALIA"
    var playerB = "CANADA"
    
    override func viewDidLoad() {
        UIView.setAnimationsEnabled(true)
        super.viewDidLoad()
        if let playA = defaults.object(forKey: playerAKey){
            playerA = playA as! String
            playerA = playerA.uppercased()
            playerB = defaults.object(forKey: playerBKey) as! String
            playerB = playerB.uppercased()
        }
        if let storedMode = defaults.object(forKey: modeKey){
            defaultMode = Mode(rawValue: storedMode as! Int)!
        }
        if let storedPlayers = defaults.object(forKey: playerOptionKey){
            defaultPlayers = PlayerOption(rawValue: storedPlayers as! Int)!
        }
        if let AIDifficulty = defaults.object(forKey: AIKey){
            defaultAI = AIDifficulty as! Int
        }
        if let numCoins = NSKeyedUnarchiver.unarchiveObject(withFile: Unlockable.CoinURL.path) as? Int{
           coins = numCoins
        }
        if let storedStats = NSKeyedUnarchiver.unarchiveObject(withFile: Unlockable.StatsURl.path) as? [String:Int]{
            statistics = storedStats
        }
        if let storedSensitivity = defaults.object(forKey: playerSensitivityKey){
            defaultSensitivity = storedSensitivity as! Float
        }
        if let fric = defaults.object(forKey: frictionKey) {
            defaultFriction = fric as! Float
        }
        // bring out unlocked
        if let storedUnlock = NSKeyedUnarchiver.unarchiveObject(withFile: Unlockable.FlagURL.path) as? [String]{
            unlockedFlags = storedUnlock
        } else{
            unlockedFlags = Unlockable().unlockedFlags
        }
        
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        screenWidth = view.frame.maxX
        scalerX = screenWidth/1136
        screenHeight = view.frame.maxY
        scalerY = screenHeight/640
        scene = GameScene(size: skView.bounds.size)
        let buttons: [UIButton] = [SettingsButton, PlayButton, ChangePlayersButton, StatsButton]
        formatMenuButtons(buttons)
        ButtonWidth.constant = 150/568*screenWidth

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Disbse of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool){
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        setBackground()
        addCoinImage("", afterText: String(coins), label: NumberCoins, numberLines: 1)
        modeString[Mode.oneMinute] = "oneMinute"
        modeString[Mode.threeMinute] = "threeMinute"
        modeString[Mode.fiveMinute] = "fiveMinute"
        modeString[Mode.tenMinute] = "tenMinute"
        modeString[Mode.threePoint] = "threePoint"
        modeString[Mode.fivePoint] = "fivePoint"
        modeString[Mode.tenPoint] = "tenPoint"
        modeString[Mode.twentyPoint] = "twentyPoint"
        stringMode["oneMinute"] = Mode.oneMinute
        stringMode["threeMinute"] = Mode.threeMinute
        stringMode["fiveMinute"] = Mode.fiveMinute
        stringMode["tenMinute"] = Mode.tenMinute
        stringMode["threePoint"] = Mode.threePoint
        stringMode["fivePoint"] = Mode.fivePoint
        stringMode["tenPoint"] = Mode.tenPoint
        stringMode["twentyPoint"] = Mode.twentyPoint
        
        CoinInfo.alpha = 0
    }
    
    
    func hideCoinInfo(){
        UIView.animate(withDuration: 0.5, animations: {
            self.CoinInfo.alpha = 0
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PlaySegue"{
            let destinationVC = segue.destination as! PlayViewController
            scene.mode = defaultMode
            scene.playerOption = defaultPlayers
            scene.AIDifficulty = defaultAI
            scene.sensitivity = defaultSensitivity
            destinationVC.scene = scene
            destinationVC.parentVC = self
            scene.cAggro = 0
            scene.cDef = 0
        }
        if segue.identifier == "SettingsSegue"{
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.defaultMode = self.defaultMode
            destinationVC.defaultPlayers = defaultPlayers
            destinationVC.defaultAI = defaultAI
            destinationVC.defaultSensitivity = defaultSensitivity
            destinationVC.defaultFriction = defaultFriction
            destinationVC.parentVC = self
        }
        if segue.identifier == "ChangePlayersSegue"{
            let destinationVC = segue.destination as! ChangePlayerViewController
            destinationVC.parentVC = self
            destinationVC.defaultA = playerA
            destinationVC.defaultB = playerB
            destinationVC.unlockedFlags = unlockedFlags
        }
    }
}

func addCoinImage(_ beforeText: String, afterText: String, label: UILabel, numberLines: Int){
    let coinImage = UIImage(named:"Coins")!
    let scaleSize = CGSize(width: 0.8*label.frame.height*coinImage.size.width/coinImage.size.height/CGFloat(numberLines),height: 0.8*label.frame.height/CGFloat(numberLines))
    UIGraphicsBeginImageContextWithOptions(scaleSize, false, 0)
    coinImage.draw(in: CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
    let resizedCoins = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let stackOfCoins = NSTextAttachment()
    stackOfCoins.image = resizedCoins
    let attachmentString = NSAttributedString(attachment: stackOfCoins)
    let coinString = NSMutableAttributedString(string: beforeText)
    coinString.append(attachmentString)
    coinString.append(NSAttributedString(string: " " + afterText))
    label.attributedText = coinString
}
func formatMenuButtons(_ buttons: [UIButton]){
    for button in buttons{
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = gold
    }
}
