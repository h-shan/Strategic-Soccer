//
//  MiniGoal.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/12/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit
class MiniGoal: SKSpriteNode {
    let mTexture: SKTexture
    let miniGoalSize: CGSize
    init(sender: SKScene){
        mTexture = SKTexture(imageNamed: "MiniGoal")
        miniGoalSize = CGSize(width: 150/568*sender.frame.midX, height: 30/568*sender.frame.midX)
        super.init(texture: mTexture, color: UIColor.clear, size:miniGoalSize)
        let miniGoalPostSize = CGSize(width: 5/568*sender.frame.midX,height: 30/568*sender.frame.midX)
        let goalPostA = GoalPost(actualSize: miniGoalPostSize)
        let goalPostB = GoalPost(actualSize: miniGoalPostSize)
        goalPostA.position = CGPoint(x: 2.5/568*sender.frame.midX, y: 15/568*sender.frame.midX)
        goalPostB.position = CGPoint(x: 27.5/568*sender.frame.midX, y: 15/568*sender.frame.midX)
        let randRotation = arc4random_uniform(6)
        switch(randRotation){
        case 0: self.zRotation = CGFloat(M_PI)/6
        case 1: self.zRotation = CGFloat(M_PI)/3
        case 2: self.zRotation = CGFloat(M_PI)/2
        case 3: self.zRotation = CGFloat(M_PI)/6
        case 4: self.zRotation = CGFloat(M_PI)/3
        default: self.zRotation = CGFloat(M_PI)/2
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
