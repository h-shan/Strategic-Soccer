//
//  ChangeTimeViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/8/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class ChangeTimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    let oneMinKey = "1 MIN"
    let threeMinKey = "3 MIN"
    let fiveMinKey = "5 MIN"
    let tenMinKey = "10 MIN"
    var items: [String]!
    var parentVC: SettingsViewController!
    var timedMode: Mode?
    
    @IBOutlet var timeOptions: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        self.timeOptions.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        items = [oneMinKey, threeMinKey, fiveMinKey,tenMinKey]
        // Do any additional setup after loading the view.
        timeOptions.showsVerticalScrollIndicator = false
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
        parentVC.pointVC.pointOptions.selectRow(at: nil, animated: false, scrollPosition: UITableViewScrollPosition.middle)
        timedMode = Mode(rawValue: indexPath.row)
        defaultMode = timedMode!
        
        _ = Foundation.Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)

    }
    func hideView (){
        self.parentVC.TimeView.isHidden = true
        parentVC.modeButtonGroup.selectButton(parentVC.ModeTimed)
        parentVC.updateModeLabel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var indexPath: IndexPath?
        
        if defaultMode.getType() == type.timed{
            indexPath = IndexPath(row: defaultMode.rawValue, section: 0)
            if indexPath != nil{
                timeOptions.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
