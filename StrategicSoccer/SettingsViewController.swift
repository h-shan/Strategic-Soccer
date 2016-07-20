//
//  SettingsViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/28/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
extension UIButton{
    func selectButton(){
        self.layer.borderWidth = 2
    }
    func unselectButton(){
        self.layer.borderWidth = 0
    }
}
class buttonGroup{
    var buttons = Set<UIButton>()
    var selectedButton: UIButton?
    init(buttons:Set<UIButton>){
        self.buttons = buttons
    }
    func addButton(button: UIButton){
        buttons.insert(button)
    }
    func selectButton(button: UIButton){
        if selectedButton != nil{
            selectedButton!.unselectButton()
        }
        selectedButton = button
        button.selectButton()
    }
}
class SettingsViewController: UIViewController {
    let timed: [String] = ["OneMinute","ThreeMinute","FiveMinute","TenMinute"]
    let points: [String] = ["ThreePoint","FivePoint","TenPoint","TwentyPoint"]
    var modeButtonGroup: buttonGroup!
    var playerButtonGroup: buttonGroup!
    var allButtons: [UIButton]!
    var defaultMode: Mode!
    var defaultPlayers: PlayerOption!
    var defaultAI: Int!
    var parent: TitleViewController!
    var timeVC: ChangeTimeViewController!
    var pointVC: ChangePointViewController!
    
    @IBOutlet weak var TimeView: UIView!
    @IBOutlet weak var PointView: UIView!
    @IBOutlet weak var PlayerFour: UIButton!
    @IBOutlet weak var PlayerThree: UIButton!
    @IBOutlet weak var ModePoints: UIButton!
    @IBOutlet weak var ModeTimed: UIButton!
    @IBOutlet weak var CurrentMode: UILabel!
    @IBOutlet weak var CurrentPlayers: UILabel!
    @IBOutlet weak var DiffValue: UILabel!
    @IBOutlet weak var DifficultyView: UIView!
    @IBOutlet weak var One : UIButton!
    @IBOutlet weak var Two : UIButton!
    @IBOutlet weak var Three : UIButton!
    @IBOutlet weak var Four : UIButton!
    @IBOutlet weak var Five : UIButton!
   
    @IBAction func AIDifficulty(sender: UIButton){
        switch(sender){
        case One: selectDifficulty(1); break
        case Two: selectDifficulty(2); break
        case Three: selectDifficulty(3); break
        case Four: selectDifficulty(4); break
        case Five: selectDifficulty(5); break
        default: break
        }
    }
    func selectDifficulty(difficulty: Int){
        defaultAI = difficulty
        DiffValue.text = String(difficulty)
        switch(difficulty){
        case 1:
            Two.layer.backgroundColor = UIColor.grayColor().CGColor
            Three.layer.backgroundColor = UIColor.grayColor().CGColor
            Four.layer.backgroundColor = UIColor.grayColor().CGColor
            Five.layer.backgroundColor = UIColor.grayColor().CGColor
        case 2:
            Two.layer.backgroundColor = UIColor.greenColor().CGColor
            Three.layer.backgroundColor = UIColor.grayColor().CGColor
            Four.layer.backgroundColor = UIColor.grayColor().CGColor
            Five.layer.backgroundColor = UIColor.grayColor().CGColor
        case 3:
            Two.layer.backgroundColor = UIColor.greenColor().CGColor
            Three.layer.backgroundColor = UIColor.greenColor().CGColor
            Four.layer.backgroundColor = UIColor.grayColor().CGColor
            Five.layer.backgroundColor = UIColor.grayColor().CGColor
        case 4:
            Two.layer.backgroundColor = UIColor.greenColor().CGColor
            Three.layer.backgroundColor = UIColor.greenColor().CGColor
            Four.layer.backgroundColor = UIColor.greenColor().CGColor
            Five.layer.backgroundColor = UIColor.grayColor().CGColor
        case 5:
            Two.layer.backgroundColor = UIColor.greenColor().CGColor
            Three.layer.backgroundColor = UIColor.greenColor().CGColor
            Four.layer.backgroundColor = UIColor.greenColor().CGColor
            Five.layer.backgroundColor = UIColor.greenColor().CGColor
        default:
            break
        }
    }
    @IBAction func PlayerFour(sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.four
        CurrentPlayers.text = "FOUR"
    }
    @IBAction func PlayerThree(sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.three
        CurrentPlayers.text = "THREE"
    }
    @IBAction func BackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func ModePoints(sender: UIButton) {
        defaultMode = Mode.tenPoint
        PointView.hidden = false
        TimeView.hidden = true
    }
    @IBAction func ModeTimed(sender: UIButton) {
        defaultMode = Mode.threeMinute
        TimeView.hidden = false
        PointView.hidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TimeView.layer.zPosition = 2
        PointView.layer.zPosition = 2
        TimeView.hidden = true
        PointView.hidden = true
        
        for button in DifficultyView.subviews{
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 5
        }
        selectDifficulty(defaultAI)
        DiffValue.text = String(defaultAI)

        setBackground()
        let modeButtons: Set<UIButton> = [ModeTimed,ModePoints]
        modeButtonGroup = buttonGroup(buttons: modeButtons)
        let playerButtons: Set<UIButton> = [PlayerThree, PlayerFour]
        playerButtonGroup = buttonGroup(buttons: playerButtons)
        allButtons = [PlayerFour,PlayerThree,ModePoints,ModeTimed]
        
        switch (defaultPlayers!){
            case PlayerOption.three:
                playerButtonGroup.selectButton(PlayerThree)
                CurrentPlayers.text = "THREE"
                break
            case PlayerOption.four:
                playerButtonGroup.selectButton(PlayerFour)
                CurrentPlayers.text = "FOUR"
                break
        }
        if (defaultMode.getType() == .timed){
            modeButtonGroup.selectButton(ModeTimed)
        }
        else{
            modeButtonGroup.selectButton(ModePoints)
        }
        updateModeLabel()
        

        // Do any additional setup after loading the view.
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        TimeView.hidden = true
        PointView.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        parent.defaultMode = defaultMode
        parent.defaultPlayers = defaultPlayers!
        parent.defaultAI = defaultAI
        defaults.setInteger(defaultMode.rawValue, forKey: modeKey)
        defaults.setInteger(defaultPlayers!.rawValue, forKey: playerOptionKey)
        defaults.setInteger(defaultAI, forKey: AIKey)
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChangeTime"{
            timeVC = segue.destinationViewController as! ChangeTimeViewController
            timeVC.parent = self
        }
        if segue.identifier == "ChangePoint"{
            pointVC = segue.destinationViewController as! ChangePointViewController
            pointVC.parent = self
        }
    
    }
    func updateModeLabel(){
        switch(defaultMode.rawValue){
        case 0:CurrentMode.text = "1 MIN"; break
        case 1:CurrentMode.text = "3 MIN"; break
        case 2:CurrentMode.text = "5 MIN"; break
        case 3:CurrentMode.text = "10 MIN"; break
        case 4:CurrentMode.text = "3 PTS"; break
        case 5:CurrentMode.text = "5 PTS"; break
        case 6:CurrentMode.text = "10 PTS"; break
        case 7:CurrentMode.text = "20 PTS"; break
        default: break
        }
    }
}
