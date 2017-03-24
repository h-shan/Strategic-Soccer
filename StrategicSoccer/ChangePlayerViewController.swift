//
//  ChangePlayerViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/29/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func enable(_ on: Bool) {
        for view in contentView.subviews {
            if view.tag != 99{
                view.isUserInteractionEnabled = on
                view.alpha = on ? 1 : 0.5
            }
        }
    }
}
class ChangePlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var lockedFlags: [String] = ["AFGHANISTAN","ALBANIA","ALGERIA","AMERICAN SAMOA","ANDORRA","ANGOLA","ANGUILLA","ANTIGUA AND BARBUDA","ARGENTINA","ARMENIA","ARUBA","AUSTRALIA","AUSTRIA" ,"AZERBAIJAN","BAHAMAS","BAHRAIN","BANGLADESH","BARBADOS","BELARUS","BELGIUM","BELIZE","BENIN","BHUTAN","BOLIVIA","BOSNIA AND HERZEGOVINA","BOTSWANA","BRAZIL","BRITISH VIRGIN ISLANDS","BRUNEI","BULGARIA","BURKINA FASO","BURUNDI","CABO VERDE","CAMBODIA","CAMEROON","CANADA","CAYMAN ISLANDS","CENTRAL AFRICAN REPUBLIC","CHAD","CHILE","CHINA","COLOMBIA","COMOROS","CONGO, DEM. REP. OF THE","CONGO, REP. OF THE","COOK ISLANDS","COSTA RICA","COTE D'IVOIRE","CROATIA","CUBA","CURACAO","CYPRUS","CZECH REPUBLIC","DENMARK","DJIBOUTI","DOMINICA","DOMINICAN REPUBLIC","ECUADOR","EGYPT","EL SALVADOR","ENGLAND","EQUATORIAL GUINEA","ERITREA","ESTONIA","ETHIOPIA","FAROE ISLANDS","FIJI","FINLAND","FRANCE","GABON","GAMBIA","GEORGIA","GERMANY","GHANA","GIBRALTAR","GREECE","GRENADA","GUAM","GUATEMALA","GUINEA","GUINEA-BISSAU","GUYANA","HAITI","HONDURAS","HONG KONG","HUNGARY","ICELAND","INDIA","INDONESIA","IRAN","IRAQ","IRELAND","ISRAEL","ITALY","JAMAICA","JAPAN","JORDAN","KAZAKHSTAN","KENYA","KIRIBATI","KOSOVO","KUWAIT","KYRGYZSTAN","LAOS","LATVIA","LEBANON","LESOTHO","LIBERIA","LIBYA","LIECHTENSTEIN","LITHUANIA","LUXEMBOURG","MACAU","MACEDONIA","MADAGASCAR","MALAWI","MALAYSIA","MALDIVES","MALI","MALTA","MAURITANIA","MAURITIUS","MEXICO","MOLDOVA","MONACO","MONGOLIA","MONTENEGRO","MONTSERRAT","MOROCCO","MOZAMBIQUE","MYANMAR","NAMIBIA","NAURU","NEPAL","NETHERLANDS","NEW CALEDONIA","NEW ZEALAND","NICARAGUA","NIGER","NIGERIA","NORTH KOREA","NORTHERN IRELAND","NORWAY","OMAN","PAKISTAN","PALESTINE","PANAMA","PAPUA NEW GUINEA","PARAGUAY","PERU","PHILIPPINES","POLAND","PORTUGAL","PUERTO RICO","QATAR","ROMANIA","RUSSIA","RWANDA","ST KITTS AND NEVIS","ST LUCIA","ST VINCENT AND THE GRENADINES","SAMOA","SAN MARINO","SAO TOME AND PRINCIPE","SAUDI ARABIA","SCOTLAND","SENEGAL","SERBIA","SEYCHELLES","SIERRA LEONE","SINGAPORE","SLOVAKIA","SLOVENIA","SOLOMON ISLANDS","SOMALIA","SOUTH AFRICA","SOUTH KOREA","SOUTH SUDAN","SPAIN","SRI LANKA","SUDAN","SURINAME","SWAZILAND","SWEDEN","SWITZERLAND","SYRIA","TAIWAN","TAJIKISTAN","TANZANIA","THAILAND","TIMOR-LESTE","TOGO","TONGA","TRUNIDAD AND TOBAGO","TUNISIA","TURKEY","TURKMENISTAN","TURKS AND CAICOS ISLANDS","U.S. VIRGIN ISLANDS","UGANDA","UKRAINE","UNITED ARAB EMIRATES","UNITED STATES","URUGUAY","UZBEKISTAN","VANUATU","VENEZUELA","VIETNAM","WALES","YEMEN","ZAMBIA","ZIMBABWE"]
    var unlockedFlags:[String]!
    var currentUnlocked = [String]()
    
    var parentVC: TitleViewController!
    var defaultA: String!
    var defaultB: String!
    var boughtCell: UITableViewCell!

    @IBOutlet weak var PlayerA: UITableView!
    @IBOutlet weak var PlayerB: UITableView!
    @IBOutlet weak var BuyFlagView: UIView!
    @IBOutlet weak var warningFlag: UIImageView!
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    @IBOutlet weak var flagName: UILabel!
    @IBOutlet weak var NotEnoughCoins: UIView!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var ConfirmationText: UILabel!
    @IBOutlet weak var BackButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var BackButtonHeight: NSLayoutConstraint!

    @IBAction func BackArrow(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func YesButton(_ sender: AnyObject){
        if coins >= 20{
            coins -= 20
            boughtCell.enable(true)
            for subview in boughtCell.contentView.subviews{
                if subview.tag == 99{
                    subview.removeFromSuperview()
                }
            }
            boughtCell.selectionStyle = .default
            currentUnlocked.append(boughtCell.textLabel!.text!)
            BuyFlagView.isHidden = true
        }
        else{
            NotEnoughCoins.isHidden = false
        }
    }
    @IBAction func OKButton(_ sender: AnyObject){
        NotEnoughCoins.isHidden = true
        BuyFlagView.isHidden = true
    }
    @IBAction func NoButton(_ sender: AnyObject){
        BuyFlagView.isHidden = true
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        BackButtonWidth.constant = 80/568*screenWidth
        BackButtonHeight.constant = 60/568*screenWidth
        self.PlayerA.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.PlayerB.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        PlayerA.layer.borderWidth = 3
        PlayerA.layer.borderColor = UIColor.black.cgColor
        PlayerB.layer.borderWidth = 3
        PlayerB.layer.borderColor = UIColor.black.cgColor
        setBackground()
        for country in unlockedFlags{
            lockedFlags.remove(at: lockedFlags.index(of: country)!)
        }
        PlayerA.showsVerticalScrollIndicator = false
        PlayerB.showsVerticalScrollIndicator = false

        unlockedFlags = unlockedFlags.sorted()
        BuyFlagView.layer.borderWidth = 5
        BuyFlagView.layer.borderColor = UIColor.black.cgColor
        
        NotEnoughCoins.layer.borderWidth = 5
        NotEnoughCoins.layer.borderColor = UIColor.black.cgColor
        
        let buttons: [UIButton] = [YesButton, NoButton, OKButton]
        formatMenuButtons(buttons)
        BuyFlagView.isHidden = true
        NotEnoughCoins.isHidden = true
        ConfirmationText.numberOfLines = 0
        addCoinImage("DO YOU WANT TO SPEND\n", afterText: "20 TO BUY THIS FLAG?", label: ConfirmationText, numberLines: 2)
        let indexPathA = IndexPath(item: findIndex(defaultA), section: 0)
        let indexPathB = IndexPath(item: findIndex(defaultB), section: 0)
        
        PlayerA.selectRow(at: indexPathA, animated: false, scrollPosition: UITableViewScrollPosition.middle)
        
        PlayerB.selectRow(at: indexPathB, animated: false, scrollPosition: UITableViewScrollPosition.middle)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lockedFlags.count + unlockedFlags.count
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let flag = findFlag(indexPath.row)
        if !unlockedFlags.contains(flag) && !currentUnlocked.contains(flag){
            return nil
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = findFlag(indexPath.row)
        cell.textLabel?.font = UIFont(name: "Optima", size: 18)
        
        let lockWidth = cell.frame.size.height/2
        let lockHeight = cell.frame.size.height*3/4
        let lock = UIButton(frame: CGRect(x: cell.frame.size.width/2-lockWidth/2,y: cell.frame.size.height/8,width: lockWidth,height: lockHeight))
        lock.tag = 99
        lock.addTarget(self, action: #selector(unlockFlag),for: .touchUpInside)
        lock.setImage(UIImage(imageLiteralResourceName: "Locked"), for: UIControlState())
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
            cell.selectionStyle = .none
        }else{
            cell.enable(true)
            for subview in cell.contentView.subviews{
                if subview.tag == 99{
                    subview.removeFromSuperview()
                    break
                }
            }
            cell.selectionStyle = .default
        }
        cell.imageView!.image = UIImage(imageLiteralResourceName: findFlag(indexPath.row))
        if tableView == PlayerB{
            cell.contentView.transform = CGAffineTransform(scaleX: -1,y: 1);
            cell.imageView!.transform = CGAffineTransform(scaleX: -1,y: 1);
            cell.textLabel!.transform = CGAffineTransform(scaleX: -1,y: 1);
            cell.textLabel?.textAlignment = .right

        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == PlayerA{
            defaultA = findFlag(indexPath.row)
        }
        if tableView == PlayerB{
            defaultB = findFlag(indexPath.row)
        }
    }
    func unlockFlag(_ sender:UIButton!){
        BuyFlagView.isHidden = false
        boughtCell = sender.superview!.superview as! UITableViewCell
        warningFlag.image = boughtCell.imageView?.image
        flagName.text = boughtCell.textLabel?.text
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if parentVC.playerA != defaultA || parentVC.playerB != defaultB {
            parentVC.playerA = defaultA
            parentVC.playerB = defaultB
            parentVC.scene.playersAdded = false
        }
        defaults.set(defaultA,forKey: playerAKey)
        defaults.set(defaultB, forKey: playerBKey)
        let unlocked = Unlockable()

        for flag in currentUnlocked{
            unlockedFlags.append(flag)
        }
        unlocked.unlockedFlags = unlockedFlags
        NSKeyedArchiver.archiveRootObject(unlockedFlags, toFile: Unlockable.FlagURL.path)
        saveCoins()
    }
    func findIndex(_ flag:String)->Int{
        if unlockedFlags.contains(flag){
            return unlockedFlags.index(of: flag)!
        }
        return unlockedFlags.count + lockedFlags.index(of: flag)!
    }
    func findFlag(_ index: Int) -> String{
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
