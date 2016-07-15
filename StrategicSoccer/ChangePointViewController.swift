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
    var parent: SettingsViewController!
    var pointMode: Mode?

    
    @IBOutlet var pointOptions: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pointOptions.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        items = [threePointKey, fivePointKey, tenPointKey, twentyPointKey]
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
        parent.timeVC.timeOptions.selectRowAtIndexPath(nil, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        pointMode = Mode(rawValue: indexPath.row + Mode.threePoint.rawValue)
        parent.defaultMode = pointMode
        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)

    }
    func hideView(){
        self.parent.PointView.hidden = true
        parent.modeButtonGroup.selectButton(parent.ModePoints)
        parent.updateModeLabel()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var indexPath: NSIndexPath?
        if parent.defaultMode!.getType() == .points{
            switch parent.defaultMode!{
            case Mode.threePoint:
                indexPath = NSIndexPath(forItem: 0 , inSection: 0)
                break
            case Mode.fivePoint:
                indexPath = NSIndexPath(forItem: 1 , inSection: 0)
                break
            case Mode.tenPoint:
                indexPath = NSIndexPath(forItem: 2 , inSection: 0)
                break
            case Mode.twentyPoint:
                indexPath = NSIndexPath(forItem: 3 , inSection: 0)
                break
            default:
                break
            }
            if indexPath != nil{
                pointOptions.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
