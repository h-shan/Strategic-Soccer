//
//  SettingsViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/28/16.
//  Copyright © 2016 HS. All rights reserved.
//

import Foundation
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

class SettingsViewController: UIViewController, UIScrollViewDelegate {
    let timed: [String] = ["OneMinute","ThreeMinute","FiveMinute","TenMinute"]
    let points: [String] = ["ThreePoint","FivePoint","TenPoint","TwentyPoint"]
    var modeButtonGroup: buttonGroup!
    var playerButtonGroup: buttonGroup!
    var allButtons: [UIButton]!
    

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
    
    @IBOutlet weak var ModeView: UIView!
    @IBOutlet weak var contentView : UIView!
    
    @IBOutlet weak var Scroll : UIScrollView!
    @IBOutlet weak var SensitivitySlider: SettingSlider!
    @IBOutlet weak var SensitivityLabel: UILabel!
    @IBOutlet weak var FrictionSlider: SettingSlider!
    @IBOutlet weak var FrictionLabel: UILabel!
    
   
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
        CurrentPlayers.text = "FOUR"
    }
    @IBAction func PlayerThree(_ sender: UIButton) {
        playerButtonGroup.selectButton(sender)
        defaultPlayers = PlayerOption.three
        CurrentPlayers.text = "THREE"
    }
    @IBAction func BackButton(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func ModePoints(_ sender: UIButton) {
        defaultMode = Mode.tenPoint
        hideView(TimeView)
        showView(PointView)
    }
    @IBAction func ModeTimed(_ sender: UIButton) {
        defaultMode = Mode.threeMinute
        hideView(PointView)
        showView(TimeView)
    }
    func setSensitivity(_ sender: UISlider){
        defaultSensitivity = sender.value.roundToPlaces(1)
        SensitivityLabel.text = String(defaultSensitivity)
        sender.setValue(defaultSensitivity, animated: false)
    }
    func setFriction(_ sender: UISlider) {
        defaultFriction = sender.value.roundToPlaces(1)
        FrictionLabel.text = String(defaultFriction)
        parentVC.scene.playersAdded = false
        sender.setValue(defaultFriction, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        TimeView.layer.zPosition = 1
        PointView.layer.zPosition = 1
        hideView(TimeView)
        hideView(PointView)
        for button in DifficultyView.subviews{
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 5
        }
        selectDifficulty(defaultAI)

        setBackground()
        let modeButtons: Set<UIButton> = [ModeTimed,ModePoints]
        modeButtonGroup = buttonGroup(buttons: modeButtons)
        let playerButtons: Set<UIButton> = [PlayerThree, PlayerFour]
        playerButtonGroup = buttonGroup(buttons: playerButtons)
        allButtons = [PlayerFour,PlayerThree,ModePoints,ModeTimed]
        
        switch (defaultPlayers){
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
        
        // sensitivity slider initialization
        SensitivitySlider.addTarget(self, action: #selector(setSensitivity), for: UIControlEvents.valueChanged)
        SensitivitySlider.minimumValue = 0.2
        SensitivitySlider.maximumValue = 5
        
        // Friction slider initialization
        FrictionSlider.addTarget(self, action: #selector(setFriction), for: UIControlEvents.valueChanged)
        FrictionSlider.minimumValue = 0
        FrictionSlider.maximumValue = 1
        
        // Do any additional setup after loading the view.
        
        // add closing of time and point views (in mode view) for random touch in content view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideModeViews(_:)))
        tapGesture.cancelsTouchesInView = false
        self.contentView.addGestureRecognizer(tapGesture)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideView(TimeView)
        hideView(PointView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defaults.set(defaultMode.rawValue, forKey: modeKey)
        defaults.set(defaultPlayers.rawValue, forKey: playerOptionKey)
        defaults.set(defaultAI, forKey: AIKey)
        defaults.set(defaultSensitivity, forKey: playerSensitivityKey)
        defaults.set(defaultFriction, forKey: frictionKey)
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SensitivitySlider.setValue(defaultSensitivity, animated: false)
        FrictionSlider.setValue(defaultFriction, animated: false)
        
        setSensitivity(SensitivitySlider)
        setFriction(FrictionSlider)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
    
    func hideView(_ currentView : UIView) {
        currentView.isHidden = true
        contentView.sendSubview(toBack: ModeView)
    }
    
    func showView(_ currentView : UIView) {
        currentView.isHidden = false
        contentView.bringSubview(toFront: ModeView)
    }
    
    func hideModeViews(_ sender : UITapGestureRecognizer) {
        if let tempView = contentView.hitTest(sender.location(in: contentView), with: nil) {
            let typeStr = String(describing: type(of: tempView))
            if typeStr == "UIView" || typeStr == "UIButton"{
                hideView(PointView)
                hideView(TimeView)
            }
        }
    }
}

extension Float {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(_ places:Int) -> Float {
        let divisor = Float(pow(10.0, Float(places)))
        return Float((self * divisor).rounded() / divisor)
    }
}

class SettingSlider : UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 12
        return newBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        setMinimumTrackImage(UIImage(named: "SliderBar"), for: UIControlState())
        setMaximumTrackImage(UIImage(named: "SliderBarEnd"), for: UIControlState())
        let sliderThumb = UIImage(named: "SliderThumb")
        setThumbImage(sliderThumb, for: UIControlState())
        super.awakeFromNib()
    }
}

@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
}
