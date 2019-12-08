//
//  TeamScene.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/08.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class TeamScene : SKScene, SKPhysicsContactDelegate{
    
    var BackButton = SKSpriteNode(imageNamed: "BackButton")
    
    var characterButton = SKSpriteNode(color: UIColor.white, size: CGSize(width: 380, height: 70))
    var weaponButton = SKSpriteNode(color: UIColor.white, size: CGSize(width: 380, height: 70))
    var developButton = SKSpriteNode(color: UIColor.white, size: CGSize(width: 380, height: 70))
    
    var characterLabel = SKLabelNode()
    var weaponLabel = SKLabelNode()
    var developLabel = SKLabelNode()
    
    let userDefaults = UserDefaults.standard//管理用のuserdefaults
    
    override func didMove(to view: SKView) {
        
        //起動した時の処理
        self.size = CGSize(width: 414, height: 896)//414x896が最適。これはiphoneXRの画面サイズ
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self //didBeginCOntactに必要
        self.physicsWorld.contactDelegate = self
        
        BackButton.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "BackButton.png"), size: BackButton.size)
        BackButton.name = "BackButton"
        BackButton.size = CGSize(width: 100, height: 100)
        BackButton.physicsBody?.categoryBitMask = 0b00000000
        BackButton.physicsBody?.collisionBitMask = 0b00000000
        BackButton.position = CGPoint(x: 364,y: 50)
        self.addChild(BackButton)
        
        characterLabel.fontSize = 30
        characterLabel.name = "characterButton"
        characterLabel.fontColor = UIColor.red
        characterLabel.color = UIColor.white
        characterLabel.position = CGPoint(x: 207, y: 700)
        characterLabel.text = "キャラクター一覧"
        self.addChild(characterLabel)
        
        weaponLabel.fontSize = 30
        weaponLabel.name = "weaponButton"
        weaponLabel.fontColor = UIColor.red
        weaponLabel.color = UIColor.white
        weaponLabel.position = CGPoint(x: 207, y: 600)
        weaponLabel.text = "武器一覧"
        self.addChild(weaponLabel)
        
        developLabel.fontSize = 30
        developLabel.name = "developButton"
        developLabel.fontColor = UIColor.red
        developLabel.color = UIColor.white
        developLabel.position = CGPoint(x: 207, y: 500)
        developLabel.text = "研究開発"
        self.addChild(developLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let location = touch.location(in: self)
            
            if self.atPoint(location).name == "characterButton" {
                self.gotoCharacterSortScene()
            } else if self.atPoint(location).name == "weaponButton" {
                self.gotoWeaponSortScene()
            } else if self.atPoint(location).name == "developButton" {
                self.gotoDevelopScene()
            } else if self.atPoint(location).name == "BackButton" {
                self.gotoHomeScene()
            }
            
        }
        
    }
    
    func gotoHomeScene() {
        
        let Scene = HomeScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    func gotoCharacterSortScene() {
        
        let Scene = CharacterSortScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    func gotoWeaponSortScene() {
        
        let Scene = WeaponSortScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    func gotoDevelopScene() {
        
        let Scene = DevelopScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
}


