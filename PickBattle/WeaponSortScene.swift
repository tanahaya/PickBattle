//
//  WeaponSortScene.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/08.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class WeaponSortScene : SKScene, SKPhysicsContactDelegate{
    
    var BackButton = SKSpriteNode(imageNamed: "BackButton")
    
    let userDefaults = UserDefaults.standard//管理用のuserdefaults
    
    var nameLabel = SKLabelNode()
    
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
        
        nameLabel.fontSize = 30
        nameLabel.fontColor = UIColor.red
        nameLabel.color = UIColor.white
        nameLabel.position = CGPoint(x: 207, y: 800)
        nameLabel.text = "武器一覧"
        self.addChild(nameLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let location = touch.location(in: self)
            
            if self.atPoint(location).name == "BackButton" {
                self.gotoTeamScene()
            }
            
        }
        
    }
    
    func gotoTeamScene() {
        
        let Scene = TeamScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    
}
