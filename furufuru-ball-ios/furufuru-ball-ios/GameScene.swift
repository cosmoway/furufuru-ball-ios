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
    var ballout_flag = true
    let title_label = SKLabelNode(fontNamed:"AppleSDGothicNeo")
    let time_label = SKLabelNode(fontNamed: "AppleSDGothicNeo")
    var next_label = SKLabelNode(fontNamed:"AppleSDGothicNeo")
    let start_label = SKLabelNode(fontNamed: "AppleSDGothicNeo")
    let join_label = SKLabelNode(fontNamed: "AppleSDGothicNeo")
    var time = "0'00"
    let help = SKSpriteNode(imageNamed: "Help")

    
    override func didMoveToView(view: SKView) {
        let margin:CGFloat = 30.0
        
        join_label.text = "join:1"
        join_label.fontSize = 30
        join_label.position = CGPointMake(self.frame.maxX-50.0, self.frame.maxY-margin)
        self.addChild(join_label)
        //helpのアイコンの設定
        help.name = "Help"
        help.position = CGPointMake(self.frame.minX+margin, self.frame.maxY-margin)
        self.addChild(help)
        
        //テキストスタート
        start_label.text = "START"
        start_label.name = "START"
        start_label.fontSize = 40
        start_label.position = CGPointMake(self.frame.midX, self.frame.midY-50.0)
        self.addChild(start_label)
        
        //ふるふるボールのテキスト
        title_label.text = "ふるふるボール"
        title_label.fontSize = 40
        title_label.position = CGPointMake(self.frame.midX,self.frame.midY+20)
        self.addChild(title_label)
        
        //リスタートのテキスト設定
        next_label.fontSize = 40
        next_label.name="NEXT"
        next_label.position = CGPoint(x: self.frame.midX,y: self.frame.midY-100)
        self.addChild(next_label)
        
        time_label.position = CGPointMake(self.frame.midX, self.frame.midY-50.0)
        time_label.fontSize = 35
        self.addChild(time_label)
        
        var radius = 40 as CGFloat
        //Circleの作成
        Circle = SKShapeNode(circleOfRadius: radius)
        //Circleに物体の設定
        Circle!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //重力はfalseにしてあります。
        Circle!.physicsBody?.affectedByGravity = false
        Circle!.position = CGPointMake(self.frame.midX, self.frame.maxY+50.0)
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle!.fillColor = UIColor.greenColor()
        self.addChild(Circle!)
        self.backgroundColor = UIColor.blackColor()
        webSocketConnect()
    }
    //リスタートのボタン
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchNode = self.nodeAtPoint(location)
            //var t: UITouch = touch as! UITouch
            if title_label.text != "" {
                if touchNode.name == "NEXT"{
                    //リスタートの処理
                    initialize()
                    title_label.text = "ふるふるボール"
                    start_label.text = "START"
                    help.hidden = false
                    webSocketConnect()
                }
            }
            if touchNode.name == "Help"{
                let dialog = CustomDialog(scene: self, frame:CGRectMake(0, 0,300, 400))
                self.view!.addSubview(dialog)
            }
            
            //スタートをタッチでサーバーに伝達
            if touchNode.name == "START"{
                //リスタートの処理
                initialize()
                if (self.isOpen()) {
                    //サーバーにメッセージをjson形式で送る処理
                    let obj: [String:AnyObject] = [
                        "game" : "start"
                    ]
                    let json = JSON(obj).toString(pretty: true)
                    self.webSocketClient?.send(json)
                }
            }
        }
    }
    //初期化
    func initialize(){
        self.physicsBody = nil
        Circle!.position = CGPointMake(self.frame.midX, self.frame.maxY+50.0)
        Circle!.physicsBody?.affectedByGravity = false
        Circle!.fillColor = UIColor.greenColor()
        count=0
        timer?.invalidate()
        next_label.text = ""
        time_label.text = ""
        title_label.text = ""
        ballout_flag = true
        time = "0'00"
        join_label.text = "join:1"
        start_label.text = ""
        help.hidden = true
    }
    
    //0.01秒ごと呼ばれる関数
    func update(){
        println(count++)
        //ミリ秒まで表示
        let ms = count % 100
        let s = (count - ms)/100
        time=String(format:"%01d'%02d",s,ms)
        //10秒たったか判定
        if s >= 10 {
            //センサー、タイマーを止めるボールを灰色にするGAME OVERと表示させる
            myMotionManager?.stopDeviceMotionUpdates()
            Circle?.physicsBody?.affectedByGravity = true
            Circle?.fillColor = UIColor.grayColor()
            timer?.invalidate()
            title_label.fontSize = 40
            title_label.text = "GAME OVER"
            time_label.text = "Time ---"
            
            if self.isOpen() {
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
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!){
        println(message)
        //messageをjsonに変えてその中身がinならスタート
        if let string = message as? String {
            let object = JSON.parse(string)
            if "in" == object["move"].asString {
                motion(40.0)
            }
            //文字を消す
            if "start" == object["game"].asString {
                start_label.text = ""
                title_label.text = ""
            }
            if "over" == object["game"].asString {
                self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                next_label.text = "NEXT"
                join_label.text = ""
                //センサーの停止
                self.myMotionManager?.stopDeviceMotionUpdates()
                if(title_label.text==""){
                        //ゲームオーバー時にカウントを表示
                        time_label.fontSize = 35
                        time_label.text="Time "+time
                        title_label.text = "RESULT"
                }
                if isOpen() {
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
        if self.isOpen() {
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
            if self.Circle?.position.x < self.frame.maxX-radius && self.Circle?.position.x > self.frame.minY+radius && self.Circle?.position.y < self.frame.maxY-radius && self.Circle?.position.y > self.frame.minY+radius {
                //加速の計算
                v_x = vp_x + (data.userAcceleration.x * weight + data.gravity.x) * 1000 * interval
                v_y = vp_y + (data.userAcceleration.y * weight + data.gravity.y) * 1000 * interval
            }
            //速度
            let v = 3000.0
            vp_x = v_x
            vp_y = v_y
            //壁に当たったか判定
            if (self.Circle!.position.x + CGFloat(v_x*interval)) <= self.frame.maxX-radius && (self.Circle!.position.x + CGFloat(v_x*interval)) >= self.frame.minX+radius {
                self.Circle!.position.x = self.Circle!.position.x + CGFloat(v_x*interval)
                
            } else {
                //ボールが壁の外にあるか
                if self.ballout_flag {
                    //ボールが外にあれば中に戻す
                    if self.Circle?.position.x<self.frame.minX+radius {
                        vp_x = 1000
                        self.Circle!.position.x += CGFloat(v_x*interval)
                        //timerが他にセットされていれば削除する
                        self.timer?.invalidate()
                        //ボールが入ってきた時タイマーに値を入れる
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "update", userInfo: nil, repeats: true)
                    }else if self.Circle?.position.x>self.frame.maxX-radius{
                        vp_x = -1000
                        self.Circle?.position.x += CGFloat(v_x*interval)
                        //timerが他にセットされていれば削除する
                        self.timer?.invalidate()
                        //ボールが入ってきた時タイマーに値を入れる
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "update", userInfo: nil, repeats: true)
                    }
                    //ボールが中に入ったら壁を作る.
                    if self.Circle!.position.x < self.frame.maxX && self.Circle!.position.x > self.frame.minX {
                        self.ballout_flag=false
                        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                        println("in")
                    }
                } else {
                    if v_x * v_x <= v * v {
                        //壁に当たった時の反発
                        if (self.Circle!.position.x + CGFloat(v_x * interval)) >= self.frame.minX + radius {
                            self.Circle!.position.x = self.frame.maxX - radius
                        } else {
                            self.Circle!.position.x = self.frame.minX + radius
                        }
                        vp_x = -vp_x * resilience
                    } else {
                        self.physicsBody = nil
                        self.Circle!.position.x = self.Circle!.position.x + CGFloat(v_x*interval)
                        //ボールが壁をすり抜けたか判定
                        if self.Circle!.position.x > self.frame.maxX+radius || self.Circle!.position.x < self.frame.minX-radius {
                            self.moveOut()
                            self.ballout_flag = true
                        }
                    }
                }
            }
            if (self.Circle!.position.y + CGFloat(v_y*interval)) <= self.frame.maxY-radius && (self.Circle!.position.y + CGFloat(v_y*interval)) >= self.frame.minY+radius {
                self.Circle!.position.y = self.Circle!.position.y + CGFloat(v_y*interval)
            } else {
                //ボールが壁の外にあるか
                if self.ballout_flag {
                    //ボールが外にあれば中に戻す
                    if self.Circle?.position.y<self.frame.minY+radius {
                        vp_y = 1000
                        self.Circle?.position.y += CGFloat(v_y*interval)
                        //timerが他にセットされていれば削除する
                        self.timer?.invalidate()
                        //ボールが入ってきた時タイマーに値を入れる
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "update", userInfo: nil, repeats: true)
                        
                    }else if self.Circle?.position.y > self.frame.maxY-radius {
                        vp_y = -1000
                        self.Circle?.position.y += CGFloat(v_y*interval)
                        //timerが他にセットされていれば削除する
                        self.timer?.invalidate()
                        //ボールが入ってきた時タイマーに値を入れる
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "update", userInfo: nil, repeats: true)
                    }
                    //ボールが中に入ったら壁を作る.
                    if self.Circle!.position.y < self.frame.maxY && self.Circle!.position.y > self.frame.minY {
                        self.ballout_flag=false
                        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
                        println("in")
                    }
                } else {
                    if v_y * v_y <= v * v {
                        //壁に当たった時の反発
                        if (self.Circle!.position.y + CGFloat(v_y * interval)) >= self.frame.minY + radius {
                            self.Circle!.position.y = self.frame.maxY - radius
                        } else {
                            self.Circle!.position.y = self.frame.minY + radius
                        }
                        vp_y = -vp_y * resilience
                    } else {
                        self.physicsBody = nil
                        self.Circle!.position.y = self.Circle!.position.y + CGFloat(v_y*interval)
                        //ボールが壁をすり抜けたか判定
                        if self.Circle!.position.y > self.frame.maxY+radius || self.Circle!.position.y < self.frame.minY-radius {
                            self.moveOut()
                            self.ballout_flag = true
                        }
                    }
                }
            }
        })
    }
}
