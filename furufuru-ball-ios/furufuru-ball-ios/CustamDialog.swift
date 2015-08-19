//
//  CustamDialog.swift
//  furufuru-ball-ios
//
//  Created by Cosmoway on 2015/08/19.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CustomDialog : UIView{
    
    var backGroundView : UIView!
    var scene : SKScene!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
}
    init(scene : SKScene,frame : CGRect){
        super.init(frame: scene.view!.bounds)
        
        // 自分が追加されたシーン.
        self.scene = scene
        
        // シーン内をポーズ.
        self.scene.view!.paused = true
        
        // シーン内のタッチを検出させなくする.
        self.scene.userInteractionEnabled = false
        
        self.layer.zPosition = 10
        
        // シーン全体を被せる背景を追加.
        self.backGroundView = UIView(frame: scene.view!.bounds)
        self.backGroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        self.backGroundView.layer.position = scene.view!.center
        self.addSubview(backGroundView)
        
        // ダイアログの背景を追加.
        let board = UIView(frame: frame)
        board.backgroundColor = UIColor.whiteColor()
        board.layer.position = backGroundView.center
        board.layer.masksToBounds = true
        board.layer.cornerRadius = 20.0
        board.layer.borderColor = UIColor.blackColor().CGColor
        self.addSubview(board)

        // ラベルを追加.
        let textView = UILabel(frame: CGRectMake(0, 0, 200,50))
        textView.text = "hogehoge"
        textView.textAlignment = NSTextAlignment.Center
        textView.layer.position = backGroundView.center
        textView.backgroundColor = UIColor.clearColor()
        textView.textColor = UIColor.blackColor()
        self.addSubview(textView)
        
        // 閉じるボタンを追加.
        let myWindowExitButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
        myWindowExitButton.tintColor = UIColor.blackColor()
        myWindowExitButton.layer.position = CGPointMake(board.bounds.maxX - myWindowExitButton.bounds.midX - 5, myWindowExitButton.bounds.midY + 5)
        
        // 追加ボタンを回転させる事で閉じるボタンっぽくみせる.
        myWindowExitButton.transform = CGAffineTransformMakeRotation(CGFloat((45.0 * M_PI) / 180.0))
        
        myWindowExitButton.addTarget(self, action: "onExitButton:", forControlEvents: UIControlEvents.TouchUpInside)
        board.addSubview(myWindowExitButton)
        
    }
    
    func onExitButton(sender : UIButton){
        
        // シーン内のボーズを解除.
        self.scene.view!.paused = false
        
        // シーン内のタッチを検出させる.
        self.scene.userInteractionEnabled = true
        
        // シーンから自身を削除.
        self.removeFromSuperview()
}
}
