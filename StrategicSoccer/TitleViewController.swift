//
//  TitleViewController.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/26/16.
//  Copyright © 2016 HS. All rights reserved.
//

import UIKit
import SpriteKit

class TitleViewController: UIViewController {
    let background = SKScene()
    @IBOutlet weak var TenPoint: UIButton!
   
    var skView: SKView!
    @IBOutlet weak var StrategicSoccerLabel: UILabel!
    
    @IBOutlet weak var ThreeMinute: UIButton!
    
    @IBAction func TenPoints(sender: UIButton) {
        let scene = GameScene(size: view.bounds.size, mode: Mode.tenPoints)
        scene.viewController = self
       
        skView.presentScene(scene)
        hideAll()
    }
    @IBAction func ThreeMinutes(sender: UIButton) {
        let scene = GameScene(size: view.bounds.size, mode: Mode.threeMinute)
        scene.viewController = self
        
        skView.presentScene(scene)
        hideAll()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        
        ThreeMinute.layer.cornerRadius = 10
        TenPoint.layer.cornerRadius = 10


        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        skView.presentScene(background)
        skView.scene!.backgroundColor = UIColor.greenColor()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func hideAll (){
        TenPoint.hidden = true
        ThreeMinute.hidden = true
        StrategicSoccerLabel.hidden = true
    }
    func showAll(){
        TenPoint.hidden = false
        ThreeMinute.hidden = false
        StrategicSoccerLabel.hidden = false
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
