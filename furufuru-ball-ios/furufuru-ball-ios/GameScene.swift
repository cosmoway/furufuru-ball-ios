//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    var myMotionManager: CMMotionManager?
    override func didMoveToView(view: SKView) {
        var radius = 40 as CGFloat
        /* Setup your scene here */
        let Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Circle.physicsBody?.affectedByGravity = false
        
        myMotionManager = CMMotionManager()
        
        // 更新周期を設定.
        myMotionManager!.accelerometerUpdateInterval = 0.01
        
        // 加速度の取得を開始.
        myMotionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(accelerometerData:CMAccelerometerData!, error:NSError!) -> Void in
            Circle.position.x += CGFloat(accelerometerData.acceleration.x)
            Circle.position.y += CGFloat(accelerometerData.acceleration.y)
        })
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
