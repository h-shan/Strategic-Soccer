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
    var scene: GameScene!
    var modeButtonGroup: buttonGroup!
    var playerButtonGroup: buttonGroup!
    var allButtons: [UIButton]!
    var defaultMode: Mode?
    var defaultPlayers: PlayerOption?
    var parent: TitleViewController!
    
    @IBOutlet weak var PlayerFour: UIButton!
    @IBOutlet weak var PlayerThree: UIButton!
    @IBOutlet weak var ModeTenPoints: UIButton!
    @IBOutlet weak var ModeThreeMinutes: UIButton!
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
    @IBAction func ModeTenPoints(sender: UIButton) {
        modeButtonGroup.selectButton(sender)
        scene.mode = Mode.tenPoints
        defaultMode = Mode.tenPoints
    }
    @IBAction func ModeThreeMinute(sender: UIButton) {
        modeButtonGroup.selectButton(sender)
        scene.mode = Mode.threeMinute
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let modeButtons: Set<UIButton> = [ModeThreeMinutes,ModeTenPoints]
        modeButtonGroup = buttonGroup(buttons: modeButtons)
        let playerButtons: Set<UIButton> = [PlayerThree, PlayerFour]
        playerButtonGroup = buttonGroup(buttons: playerButtons)
        allButtons = [PlayerFour,PlayerThree,ModeTenPoints,ModeThreeMinutes]
        for button in allButtons{
            button.layer.cornerRadius = 10
        }
        switch (defaultMode!){
            case Mode.tenPoints:
                modeButtonGroup.selectButton(ModeTenPoints)
                break
            case Mode.threeMinute:
                modeButtonGroup.selectButton(ModeThreeMinutes)
                break
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
        parent.defaultMode = defaultMode!
        parent.defaultPlayers = defaultPlayers!
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
