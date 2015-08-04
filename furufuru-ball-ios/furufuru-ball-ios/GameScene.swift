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
    var Circle: SKShapeNode?
    private var webSocketClient: SRWebSocket?
    var through_flag = false
    var ballout_flag = true
    
    override func didMoveToView(view: SKView) {
        webSocketConnect()
        //self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        var radius = 40 as CGFloat
        /* Setup your scene here */
        Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //重力はfalseにしてあります。
        Circle!.physicsBody?.affectedByGravity = false
        Circle!.position = CGPointMake(self.frame.midX, self.frame.maxY+40.0)
        
        
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle!.fillColor = UIColor.greenColor()
        self.addChild(Circle!)
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
        println(message)
        through_flag = false
        motion(40.0)
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError){
        println("error")
    }
    
    //ボールが壁をすり抜けたら呼ばれる関数
    func moveOut(){
        if (self.isOpen()) {
            //サーバーにメッセージをjson形式で送る処理
            let obj: [String:AnyObject] = [
                "move" : "out"
            ]
            let json = JSON(obj).toString(pretty: true)
            self.webSocketClient?.send(json)
        }
        //センサーの停止
        self.myMotionManager!.stopDeviceMotionUpdates()
    }
    
    func motion(radius: CGFloat) {
        myMotionManager = CMMotionManager()
        let interval = 0.03
        //反発力
        let resilience = 0.9
        // 更新周期を設定.
        myMotionManager?.deviceMotionUpdateInterval = interval
        var vp_x = 0.0
        var vp_y = 0.0

        // 加速度の取得を開始.
        myMotionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(data: CMDeviceMotion!, error:NSError!) -> Void in
            //ユーザが動いた時の加速度が小さい為10倍する
            var weight = 10.0
            var v_x = vp_x
            var v_y = vp_y
            if (self.Circle?.position.x < self.frame.maxX-radius && self.Circle?.position.x > self.frame.minY+radius && self.Circle?.position.y < self.frame.maxY-radius && self.Circle?.position.y > self.frame.minY+radius) {
                //加速の計算
                v_x = vp_x + (data.userAcceleration.x * weight + data.gravity.x) * 1000 * interval
                v_y = vp_y + (data.userAcceleration.y * weight + data.gravity.y) * 1000 * interval
            }
            //速度
            let v = 2000.0
            vp_x = v_x
            vp_y = v_y
            //壁に当たったか判定
            if ((self.Circle!.position.x + CGFloat(v_x*interval)) <= self.frame.maxX-radius && (self.Circle!.position.x + CGFloat(v_x*interval)) >= self.frame.minX+radius || self.through_flag) {
                self.Circle!.position.x = self.Circle!.position.x + CGFloat(v_x*interval)
                //ボールが壁をすり抜けたか判定
                if (self.Circle!.position.x > self.frame.maxX+radius || self.Circle!.position.x < self.frame.minX-radius) {
                    self.moveOut()
                    self.ballout_flag = true
                    self.through_flag = true
                    v_x = 0
                }
            } else {
                //ボールが壁の外にあるか
                if (self.ballout_flag) {
                    //ボールが外にあれば中に戻す
                    if (self.Circle?.position.x<self.frame.minX+radius){
                        vp_x = 30
                        self.Circle!.position.x += CGFloat(v_x)
                    }else if(self.Circle?.position.x>self.frame.maxX-radius){
                        vp_x = -30
                        self.Circle?.position.x += CGFloat(v_x)
                    }
                    //ボールが中に入ったら壁を作る.
                    if (self.Circle!.position.x < self.frame.maxX-radius && self.Circle!.position.x > self.frame.minX+radius) {
                        self.ballout_flag=false
                        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                    }
                }else{
                    if (v_x * v_x >= v * v){
                        self.physicsBody = nil
                        self.through_flag = true
                    }
                    //壁に当たった時の反発
                    if ((self.Circle!.position.x + CGFloat(v_x * interval)) >= self.frame.minX + radius) {
                        self.Circle!.position.x = self.frame.maxX - radius
                    } else {
                        self.Circle!.position.x = self.frame.minX + radius
                    }
                    vp_x = -vp_x * resilience
                }
            }
            if ((self.Circle!.position.y + CGFloat(v_y*interval)) <= self.frame.maxY-radius && (self.Circle!.position.y + CGFloat(v_y*interval)) >= self.frame.minY+radius || self.through_flag) {
                self.Circle!.position.y = self.Circle!.position.y + CGFloat(v_y*interval)
                //ボールが壁をすり抜けたか判定
                if (self.Circle!.position.y > self.frame.maxY+radius || self.Circle!.position.y < self.frame.minY-radius) {
                    self.moveOut()
                    self.ballout_flag = true
                    self.through_flag = true
                    v_y = 0
                }
            } else {
                //ボールが壁の外にあるか
                if (self.ballout_flag) {
                    //ボールが外にあれば中に戻す
                    if (self.Circle?.position.y<self.frame.minY+radius){
                        vp_y = 30
                        self.Circle?.position.y += CGFloat(v_y)
                    }else if(self.Circle?.position.y > self.frame.maxY-radius){
                        vp_y = -30
                        self.Circle?.position.y += CGFloat(v_y)
                    }
                    //ボールが中に入ったら壁を作る.
                    if (self.Circle!.position.y < self.frame.maxY-radius && self.Circle!.position.y > self.frame.minY+radius) {
                        self.ballout_flag=false
                        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                    }
                }else{
                    if (v_y * v_y >= v * v){
                        self.physicsBody = nil
                        self.through_flag = true
                    }
                    //壁に当たった時の反発
                    if ((self.Circle!.position.y + CGFloat(v_y * interval)) >= self.frame.minY + radius) {
                        self.Circle!.position.y = self.frame.maxY - radius
                    } else {
                        self.Circle!.position.y = self.frame.minY + radius
                    }
                    vp_y = -vp_y * resilience
                }
            }
        })
    }
}
