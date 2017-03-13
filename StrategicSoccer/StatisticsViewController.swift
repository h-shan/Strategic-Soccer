//
//  StatisticsViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/19/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
class StatisticsViewController: UIViewController{
    @IBOutlet weak var GW1:UILabel!
    @IBOutlet weak var GW2:UILabel!
    @IBOutlet weak var GW3:UILabel!
    @IBOutlet weak var GW4:UILabel!
    @IBOutlet weak var GW5:UILabel!
    @IBOutlet weak var GWT:UILabel!
    @IBOutlet weak var TG1:UILabel!
    @IBOutlet weak var TG2:UILabel!
    @IBOutlet weak var TG3:UILabel!
    @IBOutlet weak var TG4:UILabel!
    @IBOutlet weak var TG5:UILabel!
    @IBOutlet weak var TGT:UILabel!
    @IBOutlet weak var WP1:UILabel!
    @IBOutlet weak var WP2:UILabel!
    @IBOutlet weak var WP3:UILabel!
    @IBOutlet weak var WP4:UILabel!
    @IBOutlet weak var WP5:UILabel!
    @IBOutlet weak var WPT:UILabel!
    @IBOutlet weak var StatsView: UIView!
    @IBOutlet weak var ResetStatistics: UIButton!
    @IBOutlet weak var NoButton:UIButton!
    @IBOutlet weak var YesButton:UIButton!
    @IBOutlet weak var ResetWarning: UIView!
    @IBOutlet weak var ButtonSpacing1 : NSLayoutConstraint!
    @IBOutlet weak var ButtonSpacing2 : NSLayoutConstraint!
    @IBOutlet weak var ButtonSpacing3 : NSLayoutConstraint!
    @IBOutlet weak var ButtonSpacing4 : NSLayoutConstraint!
    @IBOutlet weak var ButtonSpacing5 : NSLayoutConstraint!
    @IBOutlet weak var BackButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var BackButtonHeight: NSLayoutConstraint!
    
    @IBAction func BackButton(_ sender:AnyObject){
        navigationController?.popViewController(animated: true)
    }
    @IBAction func resetStatistics(){
        ResetWarning.isHidden = false
    }
    @IBAction func NoTapped(){
        ResetWarning.isHidden = true
    }
    @IBAction func YesTapped(){
        for key in statistics{
            statistics.updateValue(0, forKey: key.0)
            saveStats()
        }
        copyData()
        ResetWarning.isHidden = true
    }
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        ResetWarning.isHidden = true
        setBackground()
        copyData()
        BackButtonWidth.constant = 80/568*screenWidth
        BackButtonHeight.constant = 60/568*screenWidth
        let buttons: [UIButton] = [ResetStatistics, NoButton, YesButton]
        formatMenuButtons(buttons)
        ResetWarning.layer.borderWidth = 5
        ResetWarning.layer.borderColor = UIColor.black.cgColor
        StatsView.layer.borderWidth = 5
        StatsView.layer.borderColor = UIColor.black.cgColor
        ButtonSpacing1.constant = 30/568*screenWidth
        ButtonSpacing2.constant = 50/568*screenWidth
        ButtonSpacing3.constant = 50/568*screenWidth
        ButtonSpacing4.constant = 50/568*screenWidth
        ButtonSpacing5.constant = 50/568*screenWidth
    }
    func copyData(){
        GW1.text = String(statistics[Stats.oneWon]!)
        GW2.text = String(statistics[Stats.twoWon]!)
        GW3.text = String(statistics[Stats.threeWon]!)
        GW4.text = String(statistics[Stats.fourWon]!)
        GW5.text = String(statistics[Stats.fiveWon]!)
        GWT.text = String(statistics[Stats.totalWon]!)
        TG1.text = String(statistics[Stats.totalOne]!)
        TG2.text = String(statistics[Stats.totalTwo]!)
        TG3.text = String(statistics[Stats.totalThree]!)
        TG4.text = String(statistics[Stats.totalFour]!)
        TG5.text = String(statistics[Stats.totalFive]!)
        TGT.text = String(statistics[Stats.totalGames]!)
        WP1.text = formatPercentage(statistics[Stats.oneWon]!, total: statistics[Stats.totalOne]!)
        WP2.text = formatPercentage(statistics[Stats.twoWon]!, total: statistics[Stats.totalTwo]!)
        WP3.text = formatPercentage(statistics[Stats.threeWon]!, total: statistics[Stats.totalThree]!)
        WP4.text = formatPercentage(statistics[Stats.fourWon]!, total: statistics[Stats.totalFour]!)
        WP5.text = formatPercentage(statistics[Stats.fiveWon]!, total: statistics[Stats.totalFive]!)
        WPT.text = formatPercentage(statistics[Stats.totalWon]!, total: statistics[Stats.totalGames]!)
    }
    func formatPercentage(_ won: Int, total: Int) -> String{
        if won == 0{
            return "0%"
        }
        var divided = Double(won)/Double(total)
        divided *= 100
        divided = round(divided)
        return String(Int(divided))+"%"
    }
}
