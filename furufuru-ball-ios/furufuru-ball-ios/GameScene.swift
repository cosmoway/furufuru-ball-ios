//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene ,SKPhysicsContactDelegate{
    let categoryA: UInt32 = 0x1 << 0
    var myMotionManager: CMMotionManager?
    let Circle = SKShapeNode(circleOfRadius: 40)
    let interval = 0.03
    //反発力
    let resilience = 0.9
    var vp_x = 0.0
    var vp_y = 0.0
    var v_x = 0.0
    var v_y = 0.0
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.contactTestBitMask = categoryA
        var radius = 40 as CGFloat
        /* Setup your scene here */
        //let Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Circle.physicsBody?.contactTestBitMask = categoryA
        //重力はfalseにしてあります。
        Circle.physicsBody?.affectedByGravity = false
        
        myMotionManager = CMMotionManager()
      //  let interval = 0.03
        //反発力
       // let resilience = 0.9
        // 更新周期を設定.
        myMotionManager!.accelerometerUpdateInterval = interval
        myMotionManager?.deviceMotionUpdateInterval = 0.03
       // var vp_x = 0.0
       // var vp_y = 0.0
        // 加速度の取得を開始.
        myMotionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(data: CMDeviceMotion!, error:NSError!) -> Void in
            var x = data.userAcceleration.x
            if (data.userAcceleration.x * 10>=20){
                x = 5
            }
            //加速の計算
            self.v_x = self.vp_x + (x + data.gravity.x) * 1000 * self.interval
            self.v_y = self.vp_y + (data.userAcceleration.y * 10 + data.gravity.y) * 1000 * self.interval
            
            var flag = true
            if (self.v_x*self.v_x+self.v_y*self.v_y>=900 * 900) {
                //self.physicsBody = nil
                //flag = false
            }
            self.vp_x = self.v_x
            self.vp_y = self.v_y
            //壁に当たったか判定
         //   if ((Circle.position.x + CGFloat(v_x*interval)) < self.frame.maxX-radius && (Circle.position.x + CGFloat(v_x*interval)) > self.frame.minX+radius || !flag) {
                self.Circle.position.x = self.Circle.position.x + CGFloat(self.v_x*self.interval)
        //    } else {
                //壁に当たった時の反発
        //        Circle.position.x = Circle.position.x + CGFloat(v_x*interval)
        //        vp_x = -vp_x * resilience
        //   }
         //   if ((Circle.position.y + CGFloat(v_y*interval)) < self.frame.maxY-radius && (Circle.position.y + CGFloat(v_y*interval)) > self.frame.minY+radius || !flag) {
                self.Circle.position.y = self.Circle.position.y + CGFloat(self.v_y*self.interval)
        //    } else {
       //         Circle.position.y = Circle.position.y + CGFloat(v_y*interval)
       //         vp_y = -vp_y * resilience
        //    }
            })
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func didBeginContact(contact: SKPhysicsContact) {
        //println("didBeginContact")
        Circle.position.x = Circle.position.x + CGFloat(v_x*interval)
        vp_x = -vp_x * resilience
        Circle.position.y = Circle.position.y + CGFloat(v_y*interval)
        vp_y = -vp_y * resilience
    }
}
