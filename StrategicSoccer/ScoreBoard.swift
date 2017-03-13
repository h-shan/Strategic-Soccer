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
        let rect = CGRect(origin:CGPoint(x: -75/568*x,y: -37.5/568*x),size:CGSize(width: 150/568*x,height: 75/568*x))
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = UIColor.black
        self.strokeColor = UIColor.white
        self.alpha = 0.7
        label.text = "0    0"
        label.color = UIColor.white
        label.fontSize = 25
        label.zPosition = 2
        label.position = CGPoint(x: 0, y: -10/568*x)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
