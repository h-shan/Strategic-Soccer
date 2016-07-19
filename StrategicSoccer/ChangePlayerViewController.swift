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
        for view in contentView.subviews {
            if view.tag != 99{
                view.userInteractionEnabled = on
                view.alpha = on ? 1 : 0.5
            }
        }
    }
}
class ChangePlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var lockedFlags: [String] = ["AFGHANISTAN","ALBANIA","ALGERIA","ANDORRA","ANGOLA","ANTIGUA AND BARBUDA","ARGENTINA","ARMENIA","AUSTRALIA","AUSTRIA" ,"AZERBAIJAN","BAHAMAS","BAHRAIN","BANGLADESH","BARBADOS","BELARUS","BELGIUM","BELIZE","BENIN","BHUTAN","BOLIVIA","BOSNIA AND HERZEGOVINA","BOTSWANA","BRAZIL","BRUNEI","BULGARIA","BURKINA FASO","BURUNDI","CABO VERDE","CAMBODIA","CAMEROON","CANADA","CENTRAL AFRICAN REPUBLIC","CHAD","CHILE","CHINA","COLOMBIA","COMOROS","CONGO, DEMOCRATIC REPUBLIC OF THE","CONGO, REPUBLIC OF THE","COSTA RICA","COTE D'IVOIRE","CROATIA","CUBA","CYPRUS","CZECH REPUBLIC","DENMARK","DJIBOUTI","DOMINICA","DOMINICAN REPUBLIC","ECUADOR","EGYPT","EL SALVADOR","EQUATORIAL GUINEA","ERITREA","ESTONIA","ETHIOPIA","FIJI","FINLAND","FRANCE","GABON","GAMBIA","GEORGIA","GERMANY","GHANA","GREECE","GRENADA","GUATEMALA","GUINEA","GUINEA-BISSAU","GUYANA","HAITI","HONDURAS","HUNGARY","ICELAND","INDIA","INDONESIA","IRAN","IRAQ","IRELAND","ISRAEL","ITALY","JAMAICA","JAPAN","JORDAN","KAZAKHSTAN","KENYA","KIRIBATI","KOSOVO","KUWAIT","KYRGYZSTAN","LAOS","LATVIA","LEBANON","LESOTHO","LIBERIA","LIBYA","LIECHTENSTEIN","LITHUANIA","LUXEMBOURG","MACAU","MACEDONIA","MADAGASCAR","MALAWI","MALAYSIA","MALDIVES","MALI","MALTA","MAURITANIA","MAURITIUS","MEXICO","MOLDOVA","MONACO","MONGOLIA","MONTENEGRO","MONTSERRAT","MOROCCO","MOZAMBIQUE","MYANMAR","NAMIBIA","NAURU","NEPAL","NETHERLANDS","NEW CALEDONIA","NEW ZEALAND","NICARAGUA","NIGER","NIGERIA","NORTH KOREA","NORTHERN IRELAND","NORWAY","OMAN","PAKISTAN","PALESTINE","PANAMA","PAPUA NEW GUINEA","PARAGUAY","PERU","PHILIPPINES","POLAND","PORTUGAL","PUERTO RICO","QATAR","ROMANIA","RUSSIA","RWANDA","ST KITTS AND NEVIS","ST LUCIA","ST VINCENT AND THE GRENADINES","SAMOA","SAN MARINO","SAO TOME AND PRINCIPE","SAUDI ARABIA","SCOTLAND","SENEGAL","SERBIA","SEYCHELLES","SIERRA LEONE","SINGAPORE","SLOVAKIA","SLOVENIA","SOLOMON ISLANDS","SOMALIA","SOUTH AFRICA","SOUTH KOREA","SOUTH SUDAN","SPAIN","SRI LANKA","SUDAN","SURINAME","SWAZILAND","SWEDEN","SWITZERLAND","SYRIA","TAIWAN","TAJIKISTAN","TANZANIA","THAILAND","TIMOR-LESTE","TOGO","TONGA","TRUNIDAD AND TOBAGO","TUNISIA","TURKEY","TURKMENISTAN","TURKS AND CAICOS ISLANDS","U.S. VIRGIN ISLANDS","UGANDA","UKRAINE","UNITED ARAB EMIRATES","UNITED STATES","URUGUAY","UZBEKISTAN","VANUATU","VENEZUELA","VIETNAM","WALES","YEMEN","ZAMBIA","ZIMBABWE"]
    var unlockedFlags:[String]!
    var currentUnlocked = [String]()
    
    var parent: TitleViewController!
    var defaultA: String!
    var defaultB: String!
    var boughtCell: UITableViewCell!

    @IBOutlet weak var PlayerA: UITableView!
    @IBOutlet weak var PlayerB: UITableView!
    @IBOutlet weak var BuyFlagView: UIView!
    @IBOutlet weak var warningText: UILabel!
    @IBOutlet weak var warningFlag: UIImageView!
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    @IBOutlet weak var flagName: UILabel!

    
    @IBAction func BackArrow(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func YesButton(sender: AnyObject){
        boughtCell.enable(true)
        for subview in boughtCell.contentView.subviews{
            if subview.tag == 99{
                subview.removeFromSuperview()
            }
        }
        boughtCell.selectionStyle = .Default
        currentUnlocked.append(boughtCell.textLabel!.text!)
        BuyFlagView.hidden = true
    }
    @IBAction func NoButton(sender: AnyObject){
        BuyFlagView.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PlayerA.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.PlayerB.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setBackground()
        for country in unlockedFlags{
            lockedFlags.removeAtIndex(lockedFlags.indexOf(country)!)
        }
        PlayerA.showsVerticalScrollIndicator = false
        PlayerB.showsVerticalScrollIndicator = false

        unlockedFlags = unlockedFlags.sort()
        BuyFlagView.hidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lockedFlags.count + unlockedFlags.count
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let flag = findFlag(indexPath.row)
        if !unlockedFlags.contains(flag) && !currentUnlocked.contains(flag){
            return nil
        }
        return indexPath
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = findFlag(indexPath.row)
        cell.textLabel?.font = UIFont(name: "Optima", size: 18)
        
        //let lock = UIImageView(image:UIImage(named:"Locked"))
        
        let lock = UIButton(frame: CGRectMake(0,0,1/2*cell.frame.size.height,cell.frame.size.height*3/4))
        lock.frame.origin = CGPointMake(cell.frame.size.width/2-lock.frame.width/2, cell.frame.size.height/8)
        lock.tag = 99
        lock.addTarget(self, action: #selector(unlockFlag),forControlEvents: .TouchUpInside)
        lock.setImage(UIImage(imageLiteral: "Locked"), forState: .Normal)
        if indexPath.row>=unlockedFlags.count && !currentUnlocked.contains(findFlag(indexPath.row)){
            var hasLock = false
            for view in cell.contentView.subviews{
                if view.tag == 99{
                    hasLock = true
                    break
                }
            }
            if !hasLock{
                cell.contentView.addSubview(lock)
            }
            cell.enable(false)
            cell.selectionStyle = .None
        }else{
            cell.enable(true)
            for subview in cell.contentView.subviews{
                if subview.tag == 99{
                    subview.removeFromSuperview()
                    break
                }
            }
            cell.selectionStyle = .Default
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
    func unlockFlag(sender:UIButton!){
        BuyFlagView.hidden = false
        boughtCell = sender.superview!.superview as! UITableViewCell
        warningFlag.image = boughtCell.imageView?.image
        flagName.text = boughtCell.textLabel?.text
        
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
        let unlocked = Unlockable()

        for flag in currentUnlocked{
            unlockedFlags.append(flag)
        }
        unlocked.unlockedFlags = unlockedFlags
        parent.unlockedFlags = unlockedFlags
        NSKeyedArchiver.archiveRootObject(unlockedFlags, toFile: Unlockable.ArchiveURL.path!)
        
    }
    func findIndex(flag:String)->Int{
        if unlockedFlags.contains(flag){
            return unlockedFlags.indexOf(flag)!
        }
        return unlockedFlags.count + lockedFlags.indexOf(flag)!
    }
    func findFlag(index: Int) -> String{
        if index < unlockedFlags.count{
            return unlockedFlags[index]
        }
        return lockedFlags[index-unlockedFlags.count]
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
