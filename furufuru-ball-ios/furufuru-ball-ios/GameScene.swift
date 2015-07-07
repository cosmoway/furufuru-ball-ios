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
        /* Setup your scene here */
        let Circle = SKShapeNode(circleOfRadius: 40)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
