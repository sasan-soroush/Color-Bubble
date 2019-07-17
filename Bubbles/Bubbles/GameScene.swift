//
//  GameScene.swift
//  Bubbles
//
//  Created by New User on 7/13/19.
//  Copyright © 2019 sasan soroush. All rights reserved.
//

import SpriteKit
import CoreMotion
import UIKit

class Ball : SKSpriteNode {}

extension GameScene {
    
    func setupView() {
        
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.5
        background.zPosition = -2
        addChild(background)
        
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_speed", float: 0.5),
            SKUniform(name: "u_strength", float: 3),
            SKUniform(name: "u_frequency", float: 15)
        ]
        
        let shader = SKShader(fileNamed: "background")
        shader.uniforms = uniforms
        background.shader = shader
        
        //background.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 30)))
        
        scoreLabel.fontSize = 35
        scoreLabel.text = "SCORE : 0"
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        
        
    }
    
    private func throwBall() {
        let ball_ = SKSpriteNode(imageNamed: "ballBlue")
        ball_.setScale(0.7)
        let ballRadius = ball_.frame.width/2
        let ballType = balls.randomElement()!
        let ball = Ball(imageNamed: ballType)
        //let ball = Ball(imageNamed: ballType)
        ball.position = CGPoint(x: view?.frame.midX ?? 0, y: view?.frame.maxY ?? 0)
        ball.name = ballType
        ball.setScale(0.7)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.restitution = 0
        ball.physicsBody?.friction = 0
        addChild(ball)
    }
    
}

class GameScene: SKScene {
    
    var balls = ["ballBlue" , "ballGreen" , "ballRed" , "ballPurple" , "ballYellow" ]
    var motionManager : CMMotionManager?
    var scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    var matchedBalls = Set<Ball>()
    var gotInitialValueForDevicePosition : Bool = false
    var initialX : Double = 0
    var initialY : Double = 0
    
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE : \(formattedScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        setupView()
        
        let recalibrateButton = ButtonNode(defaultImageName: "calibration", activeButtonImage: "calibration")
        recalibrateButton.position = CGPoint(x: view.frame.maxX - 50, y: view.frame.height/12)
        recalibrateButton.zPosition = 100
        recalibrateButton.setScale(0.4)
        addChild(recalibrateButton)
        recalibrateButton.action = reCalibrate
        
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
        
        let inset = view.frame.height/6
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)))
      
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
   
    override func update(_ currentTime: TimeInterval) {
        
        if let data = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: data.acceleration.x * 50 - initialX , dy: (data.acceleration.y) * 50 - initialY)
        }
        
        if score > 0 {
            score -= 1
        }
    }
    
    func reCalibrate() {
        
        if let data = motionManager?.accelerometerData {
            let x = data.acceleration.y * 50
            initialX = data.acceleration.x * 50
            initialY = data.acceleration.y * 50
            
            if x * x > 25 {
                initialY += 10
            } else {
                initialY = 0
            }
        }
        
        throwBall()
        
    }
    
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
            score += Int(matchedBalls.count * 100)
            matchedBalls.forEach {
                if let particles = SKEmitterNode(fileNamed: "Explosion") {
                    particles.position = $0.position
                    addChild(particles)
                    
                    let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3) , SKAction.removeFromParent()])
                    particles.run(removeAfterDead)
                }
                $0.removeFromParent()
            }
        }
        
        if matchedBalls.count > 8 {
            let omg = SKSpriteNode(imageNamed: "omg")
            omg.zPosition = 100
            omg.position = CGPoint(x: frame.midX, y: frame.midY)
            omg.xScale = 0.001
            omg.yScale = 0.001
            addChild(omg)
            
            let appear = SKAction.group([SKAction.scale(to: 0.5, duration: 0.25) , SKAction.fadeIn(withDuration: 0.25)])
            let disappear = SKAction.group([SKAction.scale(to: 2, duration: 0.25),SKAction.fadeOut(withDuration: 0.25)])
            let sequence = SKAction.sequence([appear , SKAction.wait(forDuration: 0.25) , disappear , SKAction.removeFromParent()])
            omg.run(sequence)
        }
        
     }
    
    
    
}
