//
//  MenuButton.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 6/21/16.
//  Copyright © 2016 HS. All rights reserved.
//
import SpriteKit

class MenuButton: SKSpriteNode{
    var label: SKLabelNode
    init(label: String, texture: SKTexture){
        self.label = SKLabelNode(fontNamed: "Georgia")
        self.label.text = label
        super.init(texture: texture, color: UIColor.clearColor(), size:CGSize(width: texture.size().width*1.5, height: texture.size().height))
        self.label.zPosition = 2
        addChild(self.label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
