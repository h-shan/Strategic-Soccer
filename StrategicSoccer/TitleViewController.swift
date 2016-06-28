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
    @IBOutlet weak var PauseButton: UIButton!
    
    
    @IBAction func PauseClicked(sender: AnyObject) {
        PauseView.hidden = false
        scene.paused = true
        scene.moveTimer?.pause()
        if scene.mode == Mode.threeMinute{
            scene.gameTimer.pause()
        }
    }
    @IBOutlet weak var PauseView: UIView!

    @IBOutlet weak var StrategicSoccerLabel: UILabel!
    
    
    
    @IBAction func TenPoints(sender: UIButton) {
        
        scene.viewController = self
        scene.mode = Mode.tenPoints
        skView.presentScene(scene)
        PauseButton.hidden = false
        hideAll()
    }
    @IBAction func ThreeMinutes(sender: UIButton) {
        
        scene.viewController = self
        scene.mode = Mode.threeMinute
        skView.presentScene(scene)
        hideAll()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        scene = GameScene(size: skView.bounds.size)
        
        ThreeMinute.layer.cornerRadius = 10
        TenPoint.layer.cornerRadius = 10
        PauseView.hidden = true
        PauseButton.hidden = true


        
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
        PauseView.hidden = true
    }
    func hideAll (){
        TenPoint.hidden = true
        ThreeMinute.hidden = true
        StrategicSoccerLabel.hidden = true
        PauseButton.hidden = false
        
    }
    func showAll(){
        TenPoint.hidden = false
        ThreeMinute.hidden = false
        StrategicSoccerLabel.hidden = false
        PauseButton.hidden = true
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Pause"{
            let destinationVC = segue.destinationViewController as! PauseViewController
            destinationVC.parent = self
            print("1")
        }
    }



}
