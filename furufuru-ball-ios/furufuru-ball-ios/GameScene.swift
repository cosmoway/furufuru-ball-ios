//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        var radius = 30 as CGFloat
        /* Setup your scene here */
        let Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //重力はfalseにしてあります。
        Circle.physicsBody?.affectedByGravity = false
        //跳ね返り空気抵抗などなくする処理
        Circle.physicsBody?.restitution = 1.0
        Circle.physicsBody?.linearDamping = 0
        Circle.physicsBody?.friction = 0
        Circle.physicsBody?.usesPreciseCollisionDetection = true
        
        let ballSpeed = 600.0
        
        //ボールが跳ね返り動く処理
        var directionX: Double = 1;
        let randX = arc4random_uniform(10) + 10
        let randY = arc4random_uniform(10) + 10
        let randV = sqrt(Double(randX * randX + randY * randY))
        let speedX = Double(randX) * ballSpeed / randV
        let speedY = Double(randY) * ballSpeed / randV
        Circle.physicsBody!.velocity = CGVectorMake(CGFloat(speedX * directionX), CGFloat(speedY))
        directionX *= -1
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
