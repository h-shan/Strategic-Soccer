//
//  ChangePointViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/9/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class ChangePointViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var items: [String] = ["3 Points", "5 Points", "10 Points", "20 Points"]
    var parent: SettingsViewController!
    var pointMode: Mode?

    
    @IBOutlet var pointOptions: UITableView!
    @IBAction func ClosingX(sender: AnyObject) {
        parent.PointView.hidden = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pointOptions.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
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
        switch(indexPath.row){
        case 0:
            pointMode = Mode.threePoint
            break
        case 1:
            pointMode = Mode.fivePoint
            break
        case 2:
            pointMode = Mode.tenPoint
            break
        default:
            pointMode = Mode.twentyPoint
            break
        }
        parent.defaultMode = pointMode

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
