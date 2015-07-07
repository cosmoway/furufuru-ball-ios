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
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        Circle.physicsBody?.affectedByGravity = true
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        // 線を引くための座標を指定. この場合はx方向に150の長さの線.
        var Point = [CGPointMake(0.0, 0.0),CGPointMake(self.frame.maxX, 0.0)]
        var SidePoint = [CGPointMake(0.0, 0.0),CGPointMake(0.0, self.frame.maxY)]
        
        // 座標から線のShapeNodeを生成.
        let UnderLine = SKShapeNode(points: &Point, count: Point.count)
        let TopLine = SKShapeNode(points: &Point, count: Point.count)
        let LeftLine = SKShapeNode(points: &SidePoint, count: SidePoint.count)
        let RightLine = SKShapeNode(points: &SidePoint, count: SidePoint.count)
        
        TopLine.position = CGPointMake(self.frame.minX, self.frame.maxY)
        TopLine.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.maxX+100,1))
        TopLine.physicsBody?.affectedByGravity = false
        TopLine.physicsBody?.dynamic = false
        
        // ShapeNodeの座標を指定.
        UnderLine.position = CGPointMake(self.frame.minX, self.frame.minY)
        UnderLine.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.maxX+100,1))
        UnderLine.physicsBody?.affectedByGravity = false
        UnderLine.physicsBody?.dynamic = false
        
        LeftLine.position = CGPointMake(self.frame.minX, self.frame.minY)
        LeftLine.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1,self.frame.maxY+100))
        LeftLine.physicsBody?.affectedByGravity = false
        LeftLine.physicsBody?.dynamic = false
        RightLine.position = CGPointMake(self.frame.maxX, self.frame.minY)
        RightLine.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1,self.frame.maxY+100))
        RightLine.physicsBody?.affectedByGravity = false
        RightLine.physicsBody?.dynamic = false
        self.addChild(Circle)
        self.addChild(UnderLine)
        self.addChild(TopLine)
        self.addChild(LeftLine)
        self.addChild(RightLine)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
