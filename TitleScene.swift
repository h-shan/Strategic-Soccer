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
        
        let startButton = SKLabelNode(fontNamed:"Times New Roman")
        startButton.text = "Start"
        startButton.fontSize = 25
        startButton.fontColor=UIColor.whiteColor()
        startButton.name = "startButton"
        startButton.position = CGPoint(x:CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*2/3)
        
        self.addChild(startButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if(node.name == "startButton"){
                let nextScene = GameScene(size: scene!.size)
                scene?.view?.presentScene(nextScene)
            }


//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
