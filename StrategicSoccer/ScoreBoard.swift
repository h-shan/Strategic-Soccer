//
//  ScoreBoard.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/6/16.
//  Copyright © 2016 HS. All rights reserved.
//

import Foundation
import SpriteKit

class ScoreBoard: SKShapeNode{
    let label = SKLabelNode()
    
    init(sender: GameScene){
        let x = sender.frame.midX
        super.init()
        let rect = CGRect(origin:CGPointMake(-75/568*x,-37.5/568*x),size:CGSizeMake(150/568*x,75/568*x))
        self.path = CGPathCreateWithRect(rect, nil)
        self.fillColor = UIColor.blackColor()
        self.strokeColor = UIColor.whiteColor()
        self.alpha = 0.7
        label.text = "0    0"
        label.color = UIColor.whiteColor()
        label.fontSize = 25
        label.zPosition = 2
        label.position = CGPointMake(0, -10/568*x)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}