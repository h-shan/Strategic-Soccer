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
    var parent: SettingsViewController!
    var timedMode: Mode?
    
    @IBOutlet var timeOptions: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeOptions.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        items = [oneMinKey, threeMinKey, fiveMinKey,tenMinKey]
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        cell.textLabel?.font = optima
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parent.pointVC.pointOptions.selectRowAtIndexPath(nil, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        timedMode = Mode(rawValue: indexPath.row)
        parent.defaultMode = timedMode
        
        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)

    }
    func hideView (){
        self.parent.TimeView.hidden = true
        parent.modeButtonGroup.selectButton(parent.ModeTimed)
        parent.updateModeLabel()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var indexPath: NSIndexPath?
        
        if parent.defaultMode!.getType() == type.timed{
            indexPath = NSIndexPath(forRow: parent.defaultMode.rawValue, inSection: 0)
            if indexPath != nil{
                timeOptions.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
