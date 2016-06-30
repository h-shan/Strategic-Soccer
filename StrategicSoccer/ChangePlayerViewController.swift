//
//  ChangePlayerViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/29/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

class ChangePlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var items: [String] = ["Argentina", "Brazil", "Spain", "Taiwan", "USA" ]
    var parent: TitleViewController!
    var scene: GameScene!
    var defaultA: String!
    var defaultB: String!

    @IBOutlet var PlayerA: UITableView!
    @IBOutlet var PlayerB: UITableView!

    @IBAction func BackArrow(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PlayerA.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.PlayerB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

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
        if tableView == PlayerA{
            defaultA = items[indexPath.row]
        }
        if tableView == PlayerB{
            defaultB = items[indexPath.row]
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let indexPathA = NSIndexPath(forItem: items.indexOf(defaultA)! , inSection: 0)
        PlayerA.selectRowAtIndexPath(indexPathA, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        let indexPathB = NSIndexPath(forItem: items.indexOf(defaultB)! , inSection: 0)
        PlayerB.selectRowAtIndexPath(indexPathB, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        parent.playerA = defaultA
        parent.playerB = defaultB
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
