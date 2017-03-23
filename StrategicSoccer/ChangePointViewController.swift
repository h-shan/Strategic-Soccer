//
//  ChangePointViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/9/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class ChangePointViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let threePointKey = "3 PTS"
    let fivePointKey = "5 PTS"
    let tenPointKey = "10 PTS"
    let twentyPointKey = "20 PTS"
    var items: [String]!
    var parentVC: SettingsViewController!
    var pointMode: Mode?

    
    @IBOutlet var pointOptions: UITableView!
   
    
    override func viewDidLoad() {
        becomeFirstResponder()

        super.viewDidLoad()
        self.pointOptions.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        items = [threePointKey, fivePointKey, tenPointKey, twentyPointKey]
        // Do any additional setup after loading the view.
        pointOptions.showsVerticalScrollIndicator = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        cell.textLabel?.font = optima
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentVC.timeVC.timeOptions.selectRow(at: nil, animated: false, scrollPosition: UITableViewScrollPosition.middle)
        pointMode = Mode(rawValue: indexPath.row + Mode.threePoint.rawValue)
        parentVC.defaultMode = pointMode
        _ = Foundation.Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)

    }
    func hideView(){
        self.parentVC.PointView.isHidden = true
        parentVC.modeButtonGroup.selectButton(parentVC.ModePoints)
        parentVC.updateModeLabel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var indexPath: IndexPath?
        if parentVC.defaultMode!.getType() == .points{
            indexPath = IndexPath(row: parentVC.defaultMode.rawValue-Mode.threePoint.rawValue, section: 0)
            if indexPath != nil{
                pointOptions.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
