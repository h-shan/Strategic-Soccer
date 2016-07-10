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
    var defaultPlayers: PlayerOption?
    var parent: TitleViewController!
    var timeVC: ChangeTimeViewController!
    var pointVC: ChangePointViewController!
    
    @IBOutlet weak var TimeView: UIView!
    @IBOutlet weak var PointView: UIView!
    @IBOutlet weak var PlayerFour: UIButton!
    @IBOutlet weak var PlayerThree: UIButton!
    @IBOutlet weak var ModePoints: UIButton!
    @IBOutlet weak var ModeTimed: UIButton!
    @IBAction func PlayerFour(sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.four
    }
    @IBAction func PlayerThree(sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.three
    }
    @IBAction func BackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
    @IBAction func ModePoints(sender: UIButton) {
        modeButtonGroup.selectButton(sender)
        defaultMode = Mode.tenPoint
        PointView.hidden = false
        TimeView.hidden = true
    }
    @IBAction func ModeTimed(sender: UIButton) {
        modeButtonGroup.selectButton(sender)
        defaultMode = Mode.threeMinute
        TimeView.hidden = false
        PointView.hidden = true
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        TimeView.hidden = true
        PointView.hidden = true
        defaultMode = parent.defaultMode
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SoccerBackground2")!)
        let modeButtons: Set<UIButton> = [ModeTimed,ModePoints]
        modeButtonGroup = buttonGroup(buttons: modeButtons)
        let playerButtons: Set<UIButton> = [PlayerThree, PlayerFour]
        playerButtonGroup = buttonGroup(buttons: playerButtons)
        allButtons = [PlayerFour,PlayerThree,ModePoints,ModeTimed]
        for button in allButtons{
            button.layer.cornerRadius = 10
        }
        switch (defaultPlayers!){
            case PlayerOption.three:
                playerButtonGroup.selectButton(PlayerThree)
                break
            case PlayerOption.four:
                playerButtonGroup.selectButton(PlayerFour)
                break
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        parent.defaultMode = defaultMode
        parent.defaultPlayers = defaultPlayers!
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

}
