//
//  PenaltyScene.swift
//  StrategicSoccer
//
//  Created by Howard Shan on 8/9/16.
//  Copyright © 2016 HS. All rights reserved.
//

import Foundation
import SpriteKit

extension UIBezierPath {
    
    
    
    
    class func transformForStartPoint(_ startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform{
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length
        
        return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
    }
    
    
    class func bezierPathWithArrowFromPoint(_ startPoint:CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        
        let xdiff: Float = Float(endPoint.x) - Float(startPoint.x)
        let ydiff: Float = Float(endPoint.y) - Float(startPoint.y)
        let length = hypotf(xdiff, ydiff)
        
        var points = [CGPoint]()
        self.getAxisAlignedArrowPoints(points, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        
        var transform: CGAffineTransform = self.transformForStartPoint(startPoint, endPoint: endPoint, length:  CGFloat(length))
        
        let cgPath: CGMutablePath = CGMutablePath()
        CGPathAddLines(cgPath, &transform, points, 7)
        cgPath.closeSubpath()
        
        let uiPath: UIBezierPath = UIBezierPath(cgPath: cgPath)
        return uiPath
    }
}
class PenaltyScene : SKScene{
    let ball = Ball()
    let goalPostA1 = GoalPost(actualSize: CGSize(width: 174*scalerY, height: 6*scalerX))
    let goalPostA2 = GoalPost(actualSize: CGSize(width: 174*scalerX, height: 6*scalerX))
    var playerA: Player!
    var playerB: Player!
    var borderBody: SKPhysicsBody!
    var setShooterPosition = false
    var defender: Player!
    var shooter: Player!
    init(gameScene: GameScene){
        super.init(size: gameScene.frame.size)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        borderBody = SKPhysicsBody(edgeLoopFrom: frame)

        self.physicsBody = borderBody
        let background = SKSpriteNode(imageNamed: "PenaltyField")
        background.position = CGPoint(x:frame.midX, y:frame.midY)
        background.size = self.frame.size
        background.zPosition=1.1
        addChild(background)
        let net = SKSpriteNode(imageNamed: "SoccerNet")
        net.size = CGSize(width: 174*scalerY,height: 520*scalerX)
        net.zRotation = CGFloat(M_PI)/2
        net.position = CGPoint(x: frame.midX,y: 87*scalerY)
        net.zPosition = 3
        addChild(net)
        goalPostA1.zPosition = 2
        goalPostA2.zPosition = 2
        goalPostA1.zRotation = CGFloat(M_PI)/2
        goalPostA2.zRotation = CGFloat(M_PI)/2
        goalPostA1.position = CGPoint(x: 310*scalerX, y: 87*scalerY)
        goalPostA2.position = CGPoint(x: 830*scalerX, y: 87*scalerY)
        addChild(goalPostA1)
        addChild(goalPostA2)
        ball.zPosition = 2
        ball.position = CGPoint(x: frame.midX,y: 300*scalerY)
        addChild(ball)
        
        playerA = Player(teamA: true, country: gameScene.countryA, sender: gameScene, name: "playerA")
        playerB = Player(teamA: true, country: gameScene.countryB, sender: gameScene, name: "playerB")
        reset(true)

    }
    func reset(_ shooterA: Bool){
        for child in self.children{
            if child is Player{
                child.removeFromParent()
            }
        }
        defender = shooterA ? playerB:playerA
        shooter = shooterA ? playerA:playerB
        defender.physicsBody!.velocity = CGVector.zero
        defender.position = CGPoint(x: frame.midX, y: 87*scalerY)
        addChild(defender)
        setShooterPosition = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !setShooterPosition{
            setShooterPosition = true
            shooter.position = touches.first!.location(in: self)
            addChild(shooter)
        }
        let arrowPath = UIBezierPath.bezierPathWithArrowFromPoint(CGPoint(x: 0,y: 0), endPoint:CGPoint(x: 0,y: 20), tailWidth:4, headWidth:8, headLength:6)
        arrowPath.fill()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
