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
    var count = 0
    var timer: NSTimer?
    var Circle: SKShapeNode?
    private var webSocketClient: SRWebSocket?
    var through_flag = false
    var ballout_flag = true
    let gameover_label = SKLabelNode(fontNamed:"Chalkduster")
    var time_label = "0.00"
    var restart_label = SKLabelNode(fontNamed:"Chalkduster")
    
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
        Circle!.position = CGPointMake(self.frame.midX, self.frame.maxY+50.0)
        
        
        gameover_label.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        self.addChild(gameover_label)
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle!.fillColor = UIColor.greenColor()
        self.addChild(Circle!)
        self.backgroundColor = UIColor.blackColor()
        //リスタートのテキスト設定
        restart_label.fontSize = 40
        restart_label.name="RESTART"
        restart_label.position = CGPoint(x: self.frame.midX,y: self.frame.midY-100)
        self.addChild(restart_label)
        
    }
    //リスタートのボタン
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchNode = self.nodeAtPoint(location)
            //var t: UITouch = touch as! UITouch
            if gameover_label.text != "" {
                if touchNode.name == "RESTART"{
                    //リスタートの処理
                    initialize()
                    webSocketConnect()
                }
            }
        }
    }
    func initialize(){
        self.physicsBody = nil
        Circle!.position = CGPointMake(self.frame.midX, self.frame.maxY+50.0)
        Circle!.physicsBody?.affectedByGravity = false
        Circle!.fillColor = UIColor.greenColor()
        count=0
        timer?.invalidate()
        gameover_label.text = ""
        restart_label.text = ""
        ballout_flag = true
        through_flag = false
        time_label = "0.00"
    }
    
    //0.01秒ごと呼ばれる関数
    func update(){
        println(count++)
        //ミリ秒まで表示
        let ms = count % 100
        let s = (count - ms)/100
        time_label=String(format:"%01d.%02d",s,ms)
        //10秒たったか判定
        if (s >= 10){
            //センサー、タイマーを止めるボールを灰色にするGAME OVERと表示させる
            myMotionManager?.stopDeviceMotionUpdates()
            Circle?.physicsBody?.affectedByGravity = true
            Circle?.fillColor = UIColor.grayColor()
            timer?.invalidate()
            gameover_label.fontSize = 40
            gameover_label.text = "GAME OVER"
            
            if (self.isOpen()) {
                //サーバーにメッセージをjson形式で送る処理
                let obj: [String:AnyObject] = [
                    "game" : "over"
                ]
                let json = JSON(obj).toString(pretty: true)
                self.webSocketClient?.send(json)
            }
        }
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
        let obj: [String:AnyObject] = [
            "game" : "start"
        ]
        let json = JSON(obj).toString(pretty: true)
        self.webSocketClient?.send(json)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!){
        println(message)
        
        //messageをjsonに変えてその中身がinならスタート
        if let string = message as? String {
            let object = JSON.parse(string)
            if ("in" == object["move"].asString) {
                motion(40.0)
            }
            if("over"==object["game"].asString){
                self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                restart_label.text = "RESTART"
                //センサーの停止
                self.myMotionManager?.stopDeviceMotionUpdates()
                if(gameover_label.text==""){
                    if (UIScreen.mainScreen().bounds.maxX<=500) {
                        //ゲームオーバー時にカウントを表示
                        gameover_label.fontSize = 20
                        gameover_label.text="あなたの記録は"+time_label+"秒でした。"
                    }else{
                        //ゲームオーバー時にカウントを表示
                        gameover_label.fontSize = 40
                        gameover_label.text="あなたの記録は"+time_label+"秒でした。"
                    }
                }
                if (isOpen()) {
                    //websocketの通信をとめる
                   webSocketClient?.closeWithCode(1000, reason: "user closed.")
                }
                
                
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError){
        println(error)
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
        //ボールが出た時タイマーを削除
        timer?.invalidate()
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
            
            vp_x = v_x
            vp_y = v_y
            let x = self.moveCircle(v_x, interval: interval, circlePosition: self.Circle!.position.x, radius: radius,resilience:resilience,speedV:vp_x,max:self.frame.maxX,min:self.frame.minX)
            self.Circle?.position.x = x.circlePositon
            vp_x = x.speedV
            let y = self.moveCircle(v_y, interval: interval, circlePosition: self.Circle!.position.y, radius: radius,resilience:resilience,speedV:vp_y,max:self.frame.maxY,min:self.frame.minY)
            self.Circle?.position.y = y.circlePositon
            vp_y = y.speedV
        })
    }
    func moveCircle(speed:Double,interval:Double,circlePosition:CGFloat,radius:CGFloat,resilience:Double,speedV:Double,max:CGFloat,min:CGFloat)->(speedV:Double,circlePositon:CGFloat){
        if ((circlePosition + CGFloat(speed*interval)) <= max-radius && (circlePosition + CGFloat(speed * interval)) >= min+radius || self.through_flag) {
            self.ballout(circlePosition,max: max,min: min,radius: radius)
            return (speedV,circlePosition + CGFloat(speed*interval))
        } else {
            //ボールが壁の外にあるか
            if (self.ballout_flag) {
                //ボールが外にあれば中に戻す
                if (circlePosition<min+radius){
                    self.timerSet()
                    return (1000,circlePosition + CGFloat(speed*interval))
                }else if(circlePosition > max-radius){
                    self.timerSet()
                    return (-1000,circlePosition + CGFloat(speed*interval))
                }
                self.makeWall(circlePosition,max: max,min: min)
            }else{
                self.speedOver(speed)
                //壁に当たった時の反発
                if ((circlePosition + CGFloat(speed * interval)) >= min + radius) {
                    return (-speedV * resilience,max - radius)
                } else {
                    return (-speedV * resilience,min + radius)
                }
            }
        }
        return (speedV,circlePosition)
    }
    func timerSet(){
        //timerが他にセットされていれば削除する
        self.timer?.invalidate()
        //ボールが入ってきた時タイマーに値を入れる
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    func makeWall(circle_position:CGFloat,max:CGFloat,min:CGFloat){
        //ボールが中に入ったら壁を作る.
        if (circle_position < max && circle_position > min) {
            self.ballout_flag=false
            self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
            println("in")
        }
    }
    func ballout(circle_position:CGFloat,max:CGFloat,min:CGFloat,radius:CGFloat){
        //ボールが壁をすり抜けたか判定
        if (circle_position > max+radius || circle_position < min-radius) {
            self.moveOut()
            self.ballout_flag = true
            self.through_flag = false
        }
    }
    func speedOver(speed:Double){
        //速度
        let v = 2000.0
        if (speed * speed >= v * v){
            self.physicsBody = nil
            self.through_flag = true
        }
    }
}
