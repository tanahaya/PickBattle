//
//  SelectScene.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/07.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SelectScene : SKScene, SKPhysicsContactDelegate {
    
    var BackButton = SKSpriteNode(imageNamed: "BackButton")
    
    let userDefaults = UserDefaults.standard//管理用のuserdefaults
    
    var world:Int = 0
    
    var stageOneButton = SKSpriteNode(color: UIColor.white, size: CGSize(width: 380, height: 70))
    var stageTwoButton = SKSpriteNode(color: UIColor.white, size: CGSize(width: 380, height: 70))
    var stageThreeButton = SKSpriteNode(color: UIColor.white, size: CGSize(width: 380, height: 70))
    
    
    override func didMove(to view: SKView) {
        
        //起動した時の処理
        self.size = CGSize(width: 414, height: 896)//414x896が最適。これはiphoneXRの画面サイズ
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self //didBeginCOntactに必要
        self.physicsWorld.contactDelegate = self
        
        world = userDefaults.integer(forKey: "world")
        
        BackButton.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "BackButton.png"), size: BackButton.size)
        BackButton.name = "BackButton"
        BackButton.size = CGSize(width: 100, height: 100)
        BackButton.physicsBody?.categoryBitMask = 0b00000000
        BackButton.physicsBody?.collisionBitMask = 0b00000000
        BackButton.position = CGPoint(x: 364,y: 50)
        self.addChild(BackButton)
        
        stageOneButton.name = "stageOne"
        stageOneButton.physicsBody?.categoryBitMask = 0b00000000
        stageOneButton.physicsBody?.collisionBitMask = 0b00000000
        stageOneButton.position = CGPoint(x: 207,y: 700)
        self.addChild(stageOneButton)
        
        stageTwoButton.name = "stageTwo"
        stageTwoButton.physicsBody?.categoryBitMask = 0b00000000
        stageTwoButton.physicsBody?.collisionBitMask = 0b00000000
        stageTwoButton.position = CGPoint(x: 207,y: 600)
        self.addChild(stageTwoButton)
        
        stageThreeButton.name = "stageThree"
        stageThreeButton.physicsBody?.categoryBitMask = 0b00000000
        stageThreeButton.physicsBody?.collisionBitMask = 0b00000000
        stageThreeButton.position = CGPoint(x: 207,y: 500)
        self.addChild(stageThreeButton)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let location = touch.location(in: self)
            
            if self.atPoint(location).name == "stageOne" {
                userDefaults.set(1, forKey: "stage")
                self.gotoGameScene()
            } else if self.atPoint(location).name == "stageTwo" {
                userDefaults.set(2, forKey: "stage")
                self.gotoGameScene()
            } else if self.atPoint(location).name == "stageThree" {
                userDefaults.set(3, forKey: "stage")
                self.gotoGameScene()
            }
            
            if self.atPoint(location).name == "BackButton" {
                self.gotoHomeScene()
            }
            
        }
        
    }
    
    func gotoHomeScene() {
        
        let Scene = HomeScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    func gotoGameScene() {
        
        let Scene = GameScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)
        
        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    
}
