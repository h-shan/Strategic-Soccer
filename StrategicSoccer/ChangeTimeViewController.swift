//
//  ChangeTimeViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/8/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class ChangeTimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var items: [String] = ["1 Minute", "3 Minutes", "5 Minutes", "10 Minutes"]
    var parent: SettingsViewController!
    var timedMode: Mode?
    
    @IBOutlet var timeOptions: UITableView!
    
    @IBAction func ClosingX(sender: AnyObject) {
        parent.TimeView.hidden = true
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeOptions.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parent.pointVC.pointOptions.selectRowAtIndexPath(nil, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        switch(indexPath.row){
        case 0:
            timedMode = Mode.oneMinute
            break
        case 1:
            timedMode = Mode.threeMinute
            break
        case 2:
            timedMode = Mode.fiveMinute
            break
        default:
            timedMode = Mode.tenMinute
            break
        }
        parent.defaultMode = timedMode

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var indexPath: NSIndexPath?
        
        if parent.defaultMode!.getType() == type.timed{
            timedMode = parent.defaultMode!
            switch (timedMode!){
            case Mode.oneMinute:
                indexPath = NSIndexPath(forItem: 0 , inSection: 0)
                break
            case Mode.threeMinute:
                indexPath = NSIndexPath(forItem: 1 , inSection: 0)
                break
            case Mode.fiveMinute:
                indexPath = NSIndexPath(forItem: 2 , inSection: 0)
                break
            case Mode.tenMinute:
                indexPath = NSIndexPath(forItem: 3 , inSection: 0)
                break
            default:
                break
            }
            if indexPath != nil{
                timeOptions.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
