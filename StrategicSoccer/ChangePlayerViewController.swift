//
//  ChangePlayerViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/29/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func enable(on: Bool) {
        self.userInteractionEnabled = on
        for view in contentView.subviews {
            if view.tag != 99{
                view.userInteractionEnabled = on
                view.alpha = on ? 1 : 0.5
            }
        }
    }
}
class ChangePlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var allFlags: [String] = ["Afghanistan","Albania","Algeria","Andorra","Angola","Antigua and Barbuda","Argentina","Armenia","Australia","Austria" ,"Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","Brunei","Bulgaria","Burkina Faso","Burundi","Cabo Verde","Cambodia","Cameroon","Canada","Central African Republic","Chad","Chile","China","Colombia","Comoros","Congo, Democratic Republic of the","Congo, Republic of the","Costa Rica","Cote d'Ivoire","Croatia","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Fiji","Finland","France","Gabon","Gambia","Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Guinea-Bissau","Guyana","Haiti","Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Israel","Italy","Jamaica","Japan","Jordan","Kazakhstan","Kenya","Kiribati","Kosovo","Kuwait","Kyrgyzstan","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macau","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Myanmar","Namibia","Nauru","Nepal","Netherlands","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","North Korea","Northern Ireland","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Puerto Rico","Qatar","Romania","Russia","Rwanda","St Kitts and Nevis","St Lucia","St Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe","Saudi Arabia","Scotland","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Korea","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Timor-Leste","Togo","Tonga","Trunidad and Tobago","Tunisia","Turkey","Turkmenistan","Turks and Caicos Islands","U.S. Virgin Islands","Uganda","Ukraine","United Arab Emirates","United States","Uruguay","Uzbekistan","Vanuatu","Venezuela","Vietnam","Wales","Yemen","Zambia","Zimbabwe"]
    var unlockedFlags:[String]!
    
    var parent: TitleViewController!
    var defaultA: String!
    var defaultB: String!

    @IBOutlet var PlayerA: UITableView!
    @IBOutlet var PlayerB: UITableView!

    @IBAction func BackArrow(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PlayerA.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.PlayerB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setBackground()
        for country in unlockedFlags{
            allFlags.removeAtIndex(allFlags.indexOf(country)!)
        }
        unlockedFlags = unlockedFlags.sort()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFlags.count + unlockedFlags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = findFlag(indexPath.row).uppercaseString
        

        cell.textLabel?.font = UIFont(name: "Optima", size: 18)
        
        let lock = UIImageView(image:UIImage(named:"Locked"))
        
        lock.frame = CGRectMake(0,0,1/2*cell.frame.size.height,cell.frame.size.height*3/4)
        lock.frame.origin = CGPointMake(cell.frame.size.width/2-lock.frame.width/2, cell.frame.size.height/8)
        lock.tag = 99
        
        if indexPath.row>=unlockedFlags.count{
            cell.contentView.addSubview(lock)

            cell.enable(false)
        }else{
            cell.enable(true)
            for subview in cell.contentView.subviews{
                if subview.tag == 99{
                    subview.removeFromSuperview()
                }
            }
        }
        cell.imageView!.image = UIImage(imageLiteral: findFlag(indexPath.row))
        if tableView == PlayerB{
            cell.contentView.transform = CGAffineTransformMakeScale(-1,1);
            cell.imageView!.transform = CGAffineTransformMakeScale(-1,1);
            cell.textLabel!.transform = CGAffineTransformMakeScale(-1,1);
            cell.textLabel?.textAlignment = .Right

        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == PlayerA{
            defaultA = findFlag(indexPath.row)
        }
        if tableView == PlayerB{
            defaultB = findFlag(indexPath.row)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let indexPathA = NSIndexPath(forItem: findIndex(defaultA), inSection: 0)
        let indexPathB = NSIndexPath(forItem: findIndex(defaultB), inSection: 0)
        
        PlayerA.selectRowAtIndexPath(indexPathA, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        
        PlayerB.selectRowAtIndexPath(indexPathB, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        parent.playerA = defaultA
        parent.playerB = defaultB
        defaults.setObject(defaultA,forKey: playerAKey)
        defaults.setObject(defaultB, forKey: playerBKey)
        
    }
    func findIndex(flag:String)->Int{
        if unlockedFlags.contains(flag){
            return unlockedFlags.indexOf(flag)!
        }
        return unlockedFlags.count + allFlags.indexOf(flag)!
    }
    func findFlag(index: Int) -> String{
        if index < unlockedFlags.count{
            return unlockedFlags[index]
        }
        return allFlags[index-unlockedFlags.count]
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
