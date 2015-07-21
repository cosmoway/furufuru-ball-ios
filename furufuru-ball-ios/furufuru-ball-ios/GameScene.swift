//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SRWebSocketDelegate{
    var myMotionManager: CMMotionManager?
    private var webSocketClient: SRWebSocket?
    
    override func didMoveToView(view: SKView) {
        webSocketConnect()
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        var radius = 40 as CGFloat
        /* Setup your scene here */
        let Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //重力はfalseにしてあります。
        Circle.physicsBody?.affectedByGravity = false
        
        myMotionManager = CMMotionManager()
        let interval = 0.03
        //反発力
        let resilience = 0.9
        // 更新周期を設定.
        myMotionManager?.deviceMotionUpdateInterval = interval
        var vp_x = 0.0
        var vp_y = 0.0
        var through_flag = true
        // 加速度の取得を開始.
        myMotionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(data: CMDeviceMotion!, error:NSError!) -> Void in
            //ユーザが動いた時の加速度が小さい為8倍する
            var twice = 10.0
            //加速の計算
            var v_x = vp_x + (data.userAcceleration.x + data.gravity.x) * 1000 * interval
            var v_y = vp_y + (data.userAcceleration.y + data.gravity.y) * 1000 * interval
            //速度
            let v = 2000.0
            if (v_x * v_x + v_y * v_y >= v * v) {
                self.physicsBody = nil
                through_flag = false
                if (self.isOpen()) {
                let obj: [String:AnyObject] = [
                    "move" : "out"
                ]
                let json = JSON(obj).toString(pretty: true)
                self.webSocketClient?.send(json)
                }
            }
            vp_x = v_x
            vp_y = v_y
            //壁に当たったか判定
            if ((Circle.position.x + CGFloat(v_x*interval)) <= self.frame.maxX-radius && (Circle.position.x + CGFloat(v_x*interval)) >= self.frame.minX+radius || !through_flag) {
                Circle.position.x = Circle.position.x + CGFloat(v_x*interval)
            } else {
                //壁に当たった時の反発
                if ((Circle.position.x + CGFloat(v_x * interval)) >= self.frame.minX + radius) {
                    Circle.position.x = self.frame.maxX - radius
                } else {
                    Circle.position.x = self.frame.minX + radius
                }
                vp_x = -vp_x * resilience
           }
            if ((Circle.position.y + CGFloat(v_y*interval)) <= self.frame.maxY-radius && (Circle.position.y + CGFloat(v_y*interval)) >= self.frame.minY+radius || !through_flag) {
                Circle.position.y = Circle.position.y + CGFloat(v_y*interval)
            } else {
                if ((Circle.position.y + CGFloat(v_y * interval)) >= self.frame.minY + radius) {
                    Circle.position.y = self.frame.maxY - radius
                } else {
                    Circle.position.y = self.frame.minY + radius
                }
                vp_y = -vp_y * resilience
            }
            /*
            if (!through_flag){
                Circle.position = CGPointMake(self.frame.midX, self.frame.maxY+30)
                Circle.physicsBody?.affectedByGravity = true
                self.myMotionManager?.stopDeviceMotionUpdates()
                if (Circle.position.y+40<self.frame.maxY){
                    println("\(Circle.position.y+40)\(self.frame.maxY)")
                    through_flag = true
                    Circle.physicsBody?.affectedByGravity = false
                    self.myMotionManager?.startDeviceMotionUpdates()
                }
            }*/
        })
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    private func isOpen() -> Bool {
        if webSocketClient != nil {
            if webSocketClient!.readyState.value == SR_OPEN.value {
                return true
            }
        }
        return false
    }
    
    private func isClosed() -> Bool {
        return !isOpen()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func webSocketConnect() {
        if isClosed() {
        var url = NSURL(string: "ws://furufuru-ball.herokuapp.com")
        var request = NSMutableURLRequest(URL: url!)
        
        webSocketClient = SRWebSocket(URLRequest: request)
        webSocketClient?.delegate = self
        webSocketClient?.open()
        }

    }
    func webSocketDidOpen(webSocket:SRWebSocket){
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!){
        
    }
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError){
        println("error")
    }
}
