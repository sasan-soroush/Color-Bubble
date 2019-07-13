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
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
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
}
