//
//  TitleScene.swift
//  StrategicSoccer
//
//  Created by Stephen on 6/14/16.
//  Copyright © 2016 HS. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.blackColor()

        let titleLabel = SKLabelNode(fontNamed:"Times New Roman")
        titleLabel.text = "Greetings, Traveler"
        titleLabel.fontSize = 45
        titleLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(titleLabel)
        
        let tenPoints = SKLabelNode(fontNamed:"Times New Roman")
        tenPoints.text = "First to 10"
        tenPoints.fontSize = 25
        tenPoints.fontColor=UIColor.whiteColor()
        tenPoints.name = "tenPoints"
        tenPoints.position = CGPoint(x:CGRectGetMidX(self.frame)*2/3, y: CGRectGetMidY(self.frame)*2/3)
        
        self.addChild(tenPoints)
        
        let threeMinutes = SKLabelNode(fontNamed:"Times New Roman")
        threeMinutes.text = "Three Minutes"
        threeMinutes.fontSize = 25
        threeMinutes.name = "threeMinutes"
        threeMinutes.position = CGPoint(x:CGRectGetMidX(self.frame)*4/3, y: CGRectGetMidY(self.frame)*2/3)
        addChild(threeMinutes)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if(node.name == "tenPoints"){
                let nextScene = GameScene(size: scene!.size, mode: Mode.tenPoints)
                scene?.view?.presentScene(nextScene)
            }
            if node.name == "threeMinutes"{
                let nextScene = GameScene(size: scene!.size, mode: Mode.threeMinute)
                scene?.view?.presentScene(nextScene)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
