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
    var gameover_timer: NSTimer?
    var Circle: SKShapeNode?
    private var webSocketClient: SRWebSocket?
    var ballout_flag = true
    let title_img = SKSpriteNode(imageNamed: "title")
    let bg_img:[SKSpriteNode] = [SKSpriteNode(imageNamed: "back1"),SKSpriteNode(imageNamed: "back2"),SKSpriteNode(imageNamed: "back3"),SKSpriteNode(imageNamed: "back4")]
    let title_ball = SKSpriteNode(imageNamed: "ball_top")
    let gameover_img = SKSpriteNode(imageNamed: "gameover")
    let mark = SKSpriteNode(imageNamed: "mark")
    let time_img = SKSpriteNode(imageNamed: "time")
    var next_img = SKSpriteNode(imageNamed: "restart")
    let start_img = SKSpriteNode(imageNamed: "start_mark")
    var join_img :[SKSpriteNode] = [SKSpriteNode(imageNamed: "join_icon")]
    let underbar = SKSpriteNode(imageNamed: "underbar")
    let time_label = SKLabelNode(fontNamed: "AppleSDGothicNeo")
    var time = ""
    let help = SKSpriteNode(imageNamed: "info_mark")
    var join = 0

    
    override func didMoveToView(view: SKView) {
        var mobile = "iphone"
        if (self.frame.height >= 1000) {
            mobile = "ipad"
        }
        let margin:CGFloat = 30.0
        for (var i=0;i<bg_img.count;i++) {
            bg_img[i].size = self.size
            bg_img[i].position = CGPointMake(self.frame.midX, self.frame.midY)
            bg_img[i].hidden = true
            bg_img[i].zPosition = 0
            self.addChild(bg_img[i])
        }
        //helpのアイコンの設定
        help.xScale = 0.3;
        help.yScale = 0.3;
        help.name = "Help"
        help.position = CGPointMake(self.frame.minX+margin, self.frame.maxY-margin)
        self.addChild(help)
        
        //title_ball
        if (mobile == "iphone") {
            title_ball.xScale = 0.2
            title_ball.yScale = 0.2
        } else {
            title_ball.xScale = 0.35
            title_ball.yScale = 0.35
        }
        title_ball.position = CGPointMake(self.frame.midX, self.frame.midY-60)
        self.addChild(title_ball)
        
        
        //スタート
        if (mobile == "iphone") {
            start_img.xScale = 0.2
            start_img.yScale = 0.2
            start_img.position = CGPointMake(self.frame.midX, self.frame.minY+100.0)
        } else {
            start_img.xScale = 0.35
            start_img.yScale = 0.35
            start_img.position = CGPointMake(self.frame.midX, self.frame.minY+200.0)
        }
        start_img.name = "START"
        self.addChild(start_img)
        
        //ふるふるボールのtitle
        if (mobile == "iphone") {
            title_img.yScale = 0.2
            title_img.xScale = 0.2
            title_img.position = CGPointMake(self.frame.midX,self.frame.maxY-150)
        } else {
            title_img.yScale = 0.35
            title_img.xScale = 0.35
            title_img.position = CGPointMake(self.frame.midX,self.frame.maxY-250)
        }
        self.addChild(title_img)
        
        //ふるふるボールのgameover
        if (mobile == "iphone") {
            gameover_img.xScale = 0.8
            gameover_img.yScale = 0.8
            gameover_img.position = CGPointMake(self.frame.midX,self.frame.midY+30)
        } else {
            gameover_img.position = CGPointMake(self.frame.midX,self.frame.midY+100)
        }
        gameover_img.zPosition = 1
        gameover_img.hidden = true
        self.addChild(gameover_img)
        
        if (mobile == "iphone") {
            mark.xScale = 0.8
            mark.yScale = 0.8
            mark.position = CGPointMake(self.frame.midX,self.frame.midY+80)
        } else {
            mark.position = CGPointMake(self.frame.midX,self.frame.midY+180)
        }
        mark.zPosition = 1
        mark.hidden = true
        self.addChild(mark)
        
        if (mobile == "iphone") {
            underbar.xScale = 0.3
            underbar.yScale = 0.3
        } else {
            underbar.xScale = 0.5
            underbar.yScale = 0.4
        }
        underbar.position = CGPointMake(self.frame.midX, self.frame.minY+10)
        self.addChild(underbar)
        
        //リスタートのテキスト設定
        if (mobile == "iphone") {
            next_img.xScale = 0.7
            next_img.yScale = 0.7
            next_img.position = CGPoint(x: self.frame.midX,y: self.frame.midY-100)
        } else {
            next_img.position = CGPoint(x: self.frame.midX,y: self.frame.midY-180)
        }
        next_img.zPosition = 1
        next_img.name="NEXT"
        next_img.hidden = true
        self.addChild(next_img)
        
        if (mobile == "iphone") {
            time_img.position = CGPointMake(self.frame.midX-30, self.frame.midY-10)
        } else {
            time_img.position = CGPointMake(self.frame.midX-30, self.frame.midY+60)
        }
        time_img.zPosition = 1
        time_img.hidden = true
        self.addChild(time_img)
        
        if (mobile == "iphone") {
            time_label.position = CGPointMake(self.frame.midX+50, self.frame.midY-23)
        } else {
           time_label.position = CGPointMake(self.frame.midX+45, self.frame.midY+48)
        }
        time_label.zPosition = 1
        time_label.text = time
        time_label.fontColor = UIColor.blackColor()
        self.addChild(time_label)
        
        let radius = 40 as CGFloat
        //Circleの作成
        Circle = SKShapeNode(circleOfRadius: radius)
        //Circleに物体の設定
        Circle!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //重力はfalseにしてあります。
        Circle!.physicsBody?.affectedByGravity = false
        Circle!.position = CGPointMake(self.frame.midX, self.frame.maxY+50)
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle!.fillColor = UIColor.rgb(r: 57, g: 57, b: 57, alpha: 1)
        Circle!.strokeColor = UIColor.rgb(r: 57, g: 57, b: 57, alpha: 1)
        Circle!.zPosition = 1
        self.addChild(Circle!)
        self.backgroundColor = UIColor.rgb(r: 240, g: 240, b: 235, alpha: 1);
        webSocketConnect()
    }
    //リスタートのボタン
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchNode = self.nodeAtPoint(location)
            if title_img.hidden {
                if touchNode.name == "NEXT"{
                    //リスタートの処理
                    initialize()
                    title_img.hidden = false
                    title_ball.hidden = false
                    underbar.hidden = false
                    start_img.hidden = false
                    start_img.name = "START"
                    bg_img[3].hidden = true
                    help.hidden = false
                    help.name = "Help"
                    join = 0
                    for (var i = 1;i<join_img.count;i++) {
                        join_img[i].hidden = false
                        self.removeChildrenInArray([join_img[i]])
                    }
                    webSocketConnect()
                }
            }
            if touchNode.name == "Help"{
                let dialog = CustomDialog(scene: self, frame:CGRectMake(0, 0,300, 400))
                self.view!.addSubview(dialog)
    
            }
            
            //スタートをタッチでサーバーに伝達
            if touchNode.name == "START"{
                if (self.isOpen()) {
                    //サーバーにメッセージをjson形式で送る処理
                    let obj: [String:AnyObject] = [
                        "game" : "start"
                    ]
                    let json = JSON(obj).toString(true)
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
        Circle!.fillColor = UIColor.rgb(r: 57, g: 57, b: 57, alpha: 1)
        Circle!.strokeColor = UIColor.rgb(r: 57, g: 57, b: 57, alpha: 1)
        count=0
        timer?.invalidate()
        next_img.hidden = true
        next_img.name = ""
        gameover_img.hidden = true
        mark.hidden = true
        time_img.hidden = true
        time_label.hidden = true
        title_img.hidden = true
        ballout_flag = true
        time = "00:00"
        start_img.hidden = true
        start_img.name = ""
        help.hidden = true
        help.name = ""
        underbar.hidden = true
        title_ball.hidden = true
    }
    
    //0.01秒ごと呼ばれる関数
    func update(){
        print(count++)
        //ミリ秒まで表示
        let ms = count % 100
        let s = (count - ms)/100
        time=String(format:"%01d:%02d",s,ms)
        //join数によってgameoverのtimeを変える
        var x = 21
        if x-join >= 10{
            x = x - join
        }else{
            x = 10
        }
        //x秒たったか判定
        if s >= x{
            
            //センサーの停止
            self.myMotionManager?.stopDeviceMotionUpdates()
            Circle?.fillColor = UIColor.rgb(r: 252, g: 238, b: 33, alpha: 1)
            Circle!.strokeColor = UIColor.rgb(r: 252, g: 238, b: 33, alpha: 1)
            if (!ballout_flag) {
                Circle?.physicsBody?.affectedByGravity = true
            }
            self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
            gameover_timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "gameover", userInfo: nil, repeats: true)
            time = "----"
            timer?.invalidate()
        }
    }
    
    private func isOpen() -> Bool {
        if webSocketClient != nil {
            if webSocketClient!.readyState.rawValue == SR_OPEN.rawValue {
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
        let url = NSURL(string: "ws://furufuru-ball.herokuapp.com")
        let request = NSMutableURLRequest(URL: url!)
        
        webSocketClient = SRWebSocket(URLRequest: request)
        webSocketClient?.delegate = self
        webSocketClient?.open()
            
        }
    }
    
    func webSocketDidOpen(webSocket:SRWebSocket){
    }
    
    func gameover() {
        if (Circle?.position.y<=self.frame.minY+45) {
            if self.isOpen() {
                //サーバーにメッセージをjson形式で送る処理
                let obj: [String:AnyObject] = [
                    "game" : "over"
                ]
                let json = JSON(obj).toString(true)
                self.webSocketClient?.send(json)
            }
            gameover_timer?.invalidate()
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!){
        print(message)
        //messageをjsonに変えてその中身がinならスタート
        if let string = message as? String {
            let object = JSON.parse(string)
            if "in" == object["move"].asString {
                motion(40.0)
            }
            //文字を消す
            if ("start" == object["game"].asString){
                //初期化処理
                initialize()
                let ran = (Int)(arc4random_uniform(3));
                bg_img[ran].hidden = false
            }
            if "over" == object["game"].asString {
                
                for (var i=0;i<bg_img.count;i++) {
                    bg_img[i].hidden = true
                }
                bg_img[3].hidden = false
                gameover_img.hidden = false
                mark.hidden = false
                next_img.hidden = false
                next_img.name = "NEXT"
                //ゲームオーバー時にカウントを表示
                time_img.hidden = false
                time_label.text = time
                time_label.hidden = false
                for (var i = 1;i<join_img.count;i++) {
                    join_img[i].hidden = true
                }

                
                if self.isOpen() {
                    //websocketの通信をとめる
                    webSocketClient?.closeWithCode(1000, reason: "user closed.")
                    
                }
            }
            //playerのjoin数が変わる度に表示を更新する
            if "change" == object["player"].asString {
                let joinCurrent = object["count"].asInt ?? 1
                //join_label.text = "join:\(join)"
                print(joinCurrent);
                if (join > joinCurrent) {
                    self.removeChildrenInArray([join_img[join]])
                    join_img.removeLast()
                }else if (join+1 < joinCurrent) {
                    for (var i=1;i<joinCurrent+1;i++) {
                        join_img.append(SKSpriteNode(imageNamed: "join_icon"))
                        join_img[i].xScale = 0.3
                        join_img[i].yScale = 0.3
                        join_img[i].position = CGPointMake(self.frame.maxX-CGFloat(30*i), self.frame.maxY-30)
                        join_img[i].zPosition = 1
                        self.addChild(join_img[i])
                    }
                } else {
                    join_img.append(SKSpriteNode(imageNamed: "join_icon"))
                    join_img[joinCurrent].xScale = 0.3
                    join_img[joinCurrent].yScale = 0.3
                    join_img[joinCurrent].position = CGPointMake(self.frame.maxX-CGFloat(30*joinCurrent), self.frame.maxY-30)
                    join_img[joinCurrent].zPosition = 1
                    self.addChild(join_img[joinCurrent])
                }
                join = joinCurrent
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError){
        print(error)
    }
    
    //ボールが壁をすり抜けたら呼ばれる関数
    func moveOut(){
        if self.isOpen() {
            //サーバーにメッセージをjson形式で送る処理
            let obj: [String:AnyObject] = [
                "move" : "out"
            ]
            let json = JSON(obj).toString(true)
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
        myMotionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(data, error) -> Void in
            //ユーザが動いた時の加速度が小さい為10倍する
            let weight = 10.0
            var v_x = vp_x
            var v_y = vp_y
            if self.Circle?.position.x < self.frame.maxX-radius && self.Circle?.position.x > self.frame.minY+radius && self.Circle?.position.y < self.frame.maxY-radius && self.Circle?.position.y > self.frame.minY+radius {
                //加速の計算
                v_x = vp_x + (data!.userAcceleration.x * weight + data!.gravity.x) * 1000 * interval
                v_y = vp_y + (data!.userAcceleration.y * weight + data!.gravity.y) * 1000 * interval
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
    //ボールを動かすメソッド
    func moveCircle(speed:Double,interval:Double,circlePosition:CGFloat,radius:CGFloat,resilience:Double,speedV:Double,max:CGFloat,min:CGFloat)->(speedV:Double,circlePositon:CGFloat){
        let v = 3000.0
        if ((circlePosition + CGFloat(speed*interval)) <= max-radius && (circlePosition + CGFloat(speed * interval)) >= min+radius) {
            
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
                if speed * speed <= v * v {
                    //壁に当たった時の反発
                    if ((circlePosition + CGFloat(speed * interval)) >= min + radius) {
                        return (-speedV * resilience,max - radius)
                    } else {
                        return (-speedV * resilience,min + radius)
                    }
                }else{
                    self.physicsBody = nil
                    self.ballout(circlePosition,max: max,min: min,radius: radius)
                    return (speedV,circlePosition + CGFloat(speed*interval))
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
            print("in")
        }
    }
    
    func ballout(circle_position:CGFloat,max:CGFloat,min:CGFloat,radius:CGFloat){
        //ボールが壁をすり抜けたか判定
        if (circle_position > max+radius || circle_position < min-radius) {
            self.moveOut()
            self.ballout_flag = true
        }
    }
}
extension UIColor {
    class func rgb(r r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
