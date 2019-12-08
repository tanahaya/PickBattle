//
//  HomeScene.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/07.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class HomeScene : SKScene, SKPhysicsContactDelegate{
    
    var MapIcon1 = SKSpriteNode(imageNamed: "ChoicePoint")
    var MapIcon2 = SKSpriteNode(imageNamed: "ChoicePoint")
    var MapIcon3 = SKSpriteNode(imageNamed: "ChoicePoint")
    var MapIcon4 = SKSpriteNode(imageNamed: "ChoicePoint")
    var MapIcon5 = SKSpriteNode(imageNamed: "ChoicePoint")
    
    var levelup = SKSpriteNode(imageNamed: "levelUp")
    
    let userDefaults = UserDefaults.standard//管理用のuserdefaults
    
    override func didMove(to view: SKView) {
        
        //起動した時の処理
        self.size = CGSize(width: 414, height: 896) //414x896が最適。これはiphoneXRの画面サイズ
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self //didBeginCOntactに必要
        
        self.backgroundColor = UIColor.black
        
        MapIcon1.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ChoicePoint"), size: MapIcon1.size)
        MapIcon1.name = "mapIcon1"
        MapIcon1.position = CGPoint(x: 207,y: 700)
        MapIcon1.size = CGSize(width: 50, height: 50)
        MapIcon1.physicsBody?.categoryBitMask = 0
        MapIcon1.physicsBody?.contactTestBitMask = 0
        MapIcon1.physicsBody?.collisionBitMask = 0
        self.addChild(MapIcon1)
        
        MapIcon2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ChoicePoint"), size: MapIcon2.size)
        MapIcon2.name = "mapIcon2"
        MapIcon2.position = CGPoint(x: 207,y: 600)
        MapIcon2.size = CGSize(width: 50, height: 50)
        MapIcon2.physicsBody?.categoryBitMask = 0
        MapIcon2.physicsBody?.contactTestBitMask = 0
        MapIcon2.physicsBody?.collisionBitMask = 0
        self.addChild(MapIcon2)
        
        MapIcon3.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ChoicePoint"), size: MapIcon3.size)
        MapIcon3.name = "mapIcon3"
        MapIcon3.position = CGPoint(x: 207,y: 500)
        MapIcon3.size = CGSize(width: 50, height: 50)
        MapIcon3.physicsBody?.categoryBitMask = 0
        MapIcon3.physicsBody?.contactTestBitMask = 0
        MapIcon3.physicsBody?.collisionBitMask = 0
        self.addChild(MapIcon3)
        
        MapIcon4.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ChoicePoint"), size: MapIcon4.size)
        MapIcon4.name = "mapIcon4"
        MapIcon4.position = CGPoint(x: 207,y: 400)
        MapIcon4.size = CGSize(width: 50, height: 50)
        MapIcon4.physicsBody?.categoryBitMask = 0
        MapIcon4.physicsBody?.contactTestBitMask = 0
        MapIcon4.physicsBody?.collisionBitMask = 0
        self.addChild(MapIcon4)
        
        MapIcon5.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ChoicePoint"), size: MapIcon5.size)
        MapIcon5.name = "mapIcon5"
        MapIcon5.position = CGPoint(x: 207,y: 300)
        MapIcon5.size = CGSize(width: 50, height: 50)
        MapIcon5.physicsBody?.categoryBitMask = 0
        MapIcon5.physicsBody?.contactTestBitMask = 0
        MapIcon5.physicsBody?.collisionBitMask = 0
        self.addChild(MapIcon5)
        
        levelup.name = "levelUp"
        levelup.anchorPoint = CGPoint(x: 0,y: 0)
        levelup.position = CGPoint(x:314,y: 100)
        levelup.size = CGSize(width: 100, height: 100)
        levelup.physicsBody?.categoryBitMask = 0
        levelup.physicsBody?.contactTestBitMask = 0
        levelup.physicsBody?.collisionBitMask = 0
        self.addChild(levelup)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let location = touch.location(in: self)
            
            switch self.atPoint(location).name  {//可変レベル
                
            case "mapIcon1":
                userDefaults.set(1, forKey: "world")
                self.gotoSelectScene()
            case "mapIcon2":
                userDefaults.set(2, forKey: "world")
                self.gotoSelectScene()
            case "mapIcon3":
                userDefaults.set(3, forKey: "world")
                self.gotoSelectScene()
            case "mapIcon4":
                userDefaults.set(4, forKey: "world")
                self.gotoSelectScene()
            case "mapIcon5":
                userDefaults.set(5, forKey: "world")
                self.gotoSelectScene()
            case "levelUp":
                self.gotoTeamScene()
            default:
                print("nomalarea")
            }
            
            
        }
        
    }
    
    func stageFlag(){
        
        //0.0なら反応しない
        MapIcon1.alpha = 1.0
        MapIcon2.alpha = 1.0
        MapIcon3.alpha = 1.0
        MapIcon4.alpha = 1.0
        MapIcon5.alpha = 1.0
        
    }
    
    func gotoSelectScene() {
        
        let Scene = SelectScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    func gotoTeamScene() {
        
        let Scene = TeamScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    
}

