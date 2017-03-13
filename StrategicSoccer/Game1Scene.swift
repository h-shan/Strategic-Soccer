//
//  Game1Scene.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 7/12/16.
//  Copyright © 2016 HS. All rights reserved.
//

import Foundation
import SpriteKit

class Game1Scene : SKScene{
    var country: String!
    var player1 = Player()
    var player2 = Player()
    var player3 = Player()
    var goalPostA1: GoalPost!
    var goalPostA2: GoalPost!
    var goalPostB1: GoalPost!
    var goalPostB2: GoalPost!
    var ball = Ball()
    var players = [Player]()
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "SoccerField")
        addChild(background)
        let actualSize = CGSize(width: 80/568*self.frame.midX, height: 5/568*self.frame.midX)
        goalPostA1 = GoalPost(actualSize: actualSize)
        goalPostA2 = GoalPost(actualSize: actualSize)
        goalPostB1 = GoalPost(actualSize: actualSize)
        goalPostB2 = GoalPost(actualSize: actualSize)
        goalPostA1.position = CGPoint(x: 40/568*frame.midX, y: frame.midY*440/320)
        goalPostA2.position = CGPoint(x: 40/568*frame.midX, y: frame.midY*200/320)
        goalPostB1.position = CGPoint(x: 1096/568*frame.midX, y: frame.midY*440/320)
        goalPostB2.position = CGPoint(x: 1096/568*frame.midX, y: frame.midY*200/320)
        self.addChild(goalPostA1)
        self.addChild(goalPostA2)
        self.addChild(goalPostB1)
        self.addChild(goalPostB2)
        player1.position = CGPoint(x: 351/568*frame.midX, y: 195/320*frame.midY)
        player2.position = CGPoint(x: 785/568*frame.midX, y: 195/320*frame.midY)
        player3.position = CGPoint(x: frame.midX, y: 570/320*frame.midY)
        players = [player1, player2, player3]
        for player in players{
            addChild(player)
        }
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(ball)
    }
}
