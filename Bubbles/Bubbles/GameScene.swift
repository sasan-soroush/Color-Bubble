//
//  GameScene.swift
//  Bubbles
//
//  Created by New User on 7/13/19.
//  Copyright © 2019 sasan soroush. All rights reserved.
//

import SpriteKit
import CoreMotion

class Ball : SKSpriteNode {}

class GameScene: SKScene {
    
    var balls = ["ballBlue" , "ballGreen" , "ballRed" , "ballPurple" , "ballYellow" ]
    var motionManager : CMMotionManager?
    var scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    var matchedBalls = Set<Ball>()
    
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE : \(formattedScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        scoreLabel.fontSize = 35
        scoreLabel.text = "SCORE : 0"
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        ball.setScale(0.7)
        let ballRadius = ball.frame.width/2
        
        for i in stride(from: ballRadius, to: view.bounds.width - ballRadius, by: ball.frame.width) {
            for j in stride(from: 50, to: view.bounds.height - ballRadius, by: ball.frame.height) {
                
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                ball.position = CGPoint(x: i, y: j)
                ball.name = ballType
                ball.setScale(0.7)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.restitution = 0
                ball.physicsBody?.friction = 0
                
                addChild(ball)
                
            }
        }
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: data.acceleration.y * -50, dy: data.acceleration.x * 50)
        }
    }
    
//    func getMatches(from node : Ball) {
//        for body in node.physicsBody!.allContactedBodies() {
//            guard let ball = body.node as? Ball else {continue}
//            guard ball.name == node.name else {continue}
//
//            if !matchedBalls.contains(ball) {
//                matchedBalls.insert(ball)
//                getMatches(from: ball)
//            }
//        }
//    }
    
    func getMatches(from startBall : Ball) {
        let matchWidth = startBall.frame.width * startBall.frame.width * 1.1
        
        for node in children {
            guard let ball = node as? Ball else {continue}
            guard ball.name == startBall.name else {continue}
            
            let dist = distance(from: startBall, to: ball)
            
            guard dist < matchWidth else {continue}
            
            if !matchedBalls.contains(ball) {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
            
        }
        
    }
    
    func distance(from : Ball, to : Ball) -> CGFloat {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) + (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let postion = touches.first?.location(in: self) else {return}
        guard let tappedBall = nodes(at: postion).first(where: {$0 is Ball}) as? Ball else {return}
        
        matchedBalls.removeAll(keepingCapacity: true)
        
        getMatches(from: tappedBall)
        
        if matchedBalls.count >= 3 {
            score += Int(pow(2, Double(2)))
            matchedBalls.forEach {$0.removeFromParent()}
        }
     }
}
