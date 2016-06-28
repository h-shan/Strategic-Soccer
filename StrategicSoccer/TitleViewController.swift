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
    var scene: GameScene!
    var skView: SKView!

    @IBOutlet weak var TenPoint: UIButton!
    @IBOutlet weak var ThreeMinute: UIButton!
    
    @IBOutlet weak var StrategicSoccerLabel: UILabel!
    
    
    
    @IBAction func TenPoints(sender: UIButton) {
        
        
        scene.mode = Mode.tenPoints
        
        //hideAll()
    }
    @IBAction func ThreeMinutes(sender: UIButton) {
        
        scene.mode = Mode.threeMinute
        //hideAll()
        
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
        scene = GameScene(size: skView.bounds.size)
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GameSegue"{
            let destinationVC = segue.destinationViewController as! GameViewController
            destinationVC.scene = scene
            destinationVC.parent = self
        }
    }



}
