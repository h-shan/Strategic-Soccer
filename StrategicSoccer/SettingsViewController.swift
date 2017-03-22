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
        self.layer.borderWidth = 3.5
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
    func addButton(_ button: UIButton){
        buttons.insert(button)
    }
    func selectButton(_ button: UIButton){
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
    var defaultSensitivity: Float!

    var parentVC: TitleViewController!
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
    
    @IBOutlet weak var ButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var GreenButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var leadingMargin: NSLayoutConstraint!
    @IBOutlet weak var endingMargin: NSLayoutConstraint!
    @IBOutlet weak var BackButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var BackButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var SensitivitySlider: UISlider!
    @IBOutlet weak var SensitivityLabel: UILabel!
    
   
    @IBAction func AIDifficulty(_ sender: UIButton){
        switch(sender){
        case One: selectDifficulty(1); break
        case Two: selectDifficulty(2); break
        case Three: selectDifficulty(3); break
        case Four: selectDifficulty(4); break
        case Five: selectDifficulty(5); break
        default: break
        }
    }
    func selectDifficulty(_ difficulty: Int){
        defaultAI = difficulty
        DiffValue.text = String(difficulty)  +  " \u{200c}"
        switch(difficulty){
        case 1:
            Two.layer.backgroundColor = UIColor.gray.cgColor
            Three.layer.backgroundColor = UIColor.gray.cgColor
            Four.layer.backgroundColor = UIColor.gray.cgColor
            Five.layer.backgroundColor = UIColor.gray.cgColor
        case 2:
            Two.layer.backgroundColor = UIColor.green.cgColor
            Three.layer.backgroundColor = UIColor.gray.cgColor
            Four.layer.backgroundColor = UIColor.gray.cgColor
            Five.layer.backgroundColor = UIColor.gray.cgColor
        case 3:
            Two.layer.backgroundColor = UIColor.green.cgColor
            Three.layer.backgroundColor = UIColor.green.cgColor
            Four.layer.backgroundColor = UIColor.gray.cgColor
            Five.layer.backgroundColor = UIColor.gray.cgColor
        case 4:
            Two.layer.backgroundColor = UIColor.green.cgColor
            Three.layer.backgroundColor = UIColor.green.cgColor
            Four.layer.backgroundColor = UIColor.green.cgColor
            Five.layer.backgroundColor = UIColor.gray.cgColor
        case 5:
            Two.layer.backgroundColor = UIColor.green.cgColor
            Three.layer.backgroundColor = UIColor.green.cgColor
            Four.layer.backgroundColor = UIColor.green.cgColor
            Five.layer.backgroundColor = UIColor.green.cgColor
        default:
            break
        }
    }
    @IBAction func PlayerFour(_ sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.four
        CurrentPlayers.text = "FOUR " +  " \u{200c}"
    }
    @IBAction func PlayerThree(_ sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.three
        CurrentPlayers.text = "THREE" + " \u{200c}"
    }
    @IBAction func BackButton(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func ModePoints(_ sender: UIButton) {
        defaultMode = Mode.tenPoint
        PointView.isHidden = false
        TimeView.isHidden = true
    }
    @IBAction func ModeTimed(_ sender: UIButton) {
        defaultMode = Mode.threeMinute
        TimeView.isHidden = false
        PointView.isHidden = true
    }
    func setSensitivity(_ sender: UISlider){
        defaultSensitivity = sender.value.roundToPlaces(1)
        SensitivityLabel.text = String(defaultSensitivity) + " \u{200c}"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TimeView.layer.zPosition = 2
        PointView.layer.zPosition = 2
        TimeView.isHidden = true
        PointView.isHidden = true
        BackButtonWidth.constant = 80/568*screenWidth
        BackButtonHeight.constant = 60/568*screenWidth
        for button in DifficultyView.subviews{
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 5
        }
        selectDifficulty(defaultAI)
        DiffValue.text = String(defaultAI) + " \u{200c}"

        setBackground()
        let modeButtons: Set<UIButton> = [ModeTimed,ModePoints]
        modeButtonGroup = buttonGroup(buttons: modeButtons)
        let playerButtons: Set<UIButton> = [PlayerThree, PlayerFour]
        playerButtonGroup = buttonGroup(buttons: playerButtons)
        allButtons = [PlayerFour,PlayerThree,ModePoints,ModeTimed]
        
        switch (defaultPlayers!){
            case PlayerOption.three:
                playerButtonGroup.selectButton(PlayerThree)
                CurrentPlayers.text = "THREE \u{200c}"
                break
            case PlayerOption.four:
                playerButtonGroup.selectButton(PlayerFour)
                CurrentPlayers.text = "FOUR \u{200c}"
                break
        }
        if (defaultMode.getType() == .timed){
            modeButtonGroup.selectButton(ModeTimed)
        }
        else{
            modeButtonGroup.selectButton(ModePoints)
        }
        updateModeLabel()
        SensitivitySlider.addTarget(self, action: #selector(setSensitivity), for: UIControlEvents.valueChanged)
        SensitivitySlider.minimumValue = 1
        SensitivitySlider.maximumValue = 5
        SensitivitySlider.setValue(defaultSensitivity, animated: false)
        
        // Do any additional setup after loading the view.
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        TimeView.isHidden = true
        PointView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        parentVC.defaultMode = defaultMode
        parentVC.defaultPlayers = defaultPlayers!
        parentVC.defaultAI = defaultAI
        parentVC.defaultSensitivity = defaultSensitivity
        defaults.set(defaultMode.rawValue, forKey: modeKey)
        defaults.set(defaultPlayers!.rawValue, forKey: playerOptionKey)
        defaults.set(defaultAI, forKey: AIKey)
        defaults.set(defaultSensitivity, forKey: playerSensitivityKey)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeTime"{
            timeVC = segue.destination as! ChangeTimeViewController
            timeVC.parentVC = self
        }
        if segue.identifier == "ChangePoint"{
            pointVC = segue.destination as! ChangePointViewController
            pointVC.parentVC = self
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
        CurrentMode.text =  CurrentMode.text! + " \u{200c}"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ButtonWidth.constant = 46.8/568*screenWidth
        SensitivitySlider.setMinimumTrackImage(UIImage(named: "SliderBar"), for: UIControlState())
        SensitivitySlider.setMaximumTrackImage(UIImage(named: "SliderBarEnd"), for: UIControlState())
        let sliderThumb = UIImage(named: "SliderThumb")
        SensitivitySlider.setThumbImage(sliderThumb, for: UIControlState())
        SensitivityLabel.text = String(defaultSensitivity) + " \u{200c}"
        GreenButtonWidth.constant = 110/568*screenWidth
        
        leadingMargin.constant = 30/568*screenWidth
        endingMargin.constant = -30/568*screenWidth
        print(ButtonWidth.constant)
        print(DifficultyView.layer.frame.width)
       
    }
}
extension Float {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(_ places:Int) -> Float {
        let divisor = Float(pow(10.0, Float(places)))
        return Float((self * divisor).rounded() / divisor)
        
    }
}
class CustomUISlider : UISlider
{
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 12
        return newBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        self.setThumbImage(UIImage(named: "customThumb"), for: UIControlState())
        super.awakeFromNib()
    }
}
