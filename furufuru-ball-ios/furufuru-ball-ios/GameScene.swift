//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit

let Circle = SKShapeNode(circleOfRadius: 40)

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        var radius = 40 as CGFloat
        /* Setup your scene here */
        //let Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Circle.physicsBody?.affectedByGravity = true
        Circle.physicsBody?.velocity = CGVectorMake(1,1)
        Circle.physicsBody?.restitution = 1.0
        Circle.physicsBody?.linearDamping = 0
        Circle.physicsBody?.friction = 0
        Circle.physicsBody?.usesPreciseCollisionDetection = true
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        Circle.position.x++
    }
}
