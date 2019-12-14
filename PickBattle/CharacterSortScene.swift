//
//  CharacterSortScene.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/08.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import RealmSwift

class CharacterSortScene : SKScene, SKPhysicsContactDelegate {
    
    var BackButton = SKSpriteNode(imageNamed: "BackButton")
    var levelup = SKSpriteNode(imageNamed: "levelUp")
    
    let realm = try! Realm()
    
    var nameLabel = SKLabelNode()
    
    var gameTableView = GameTableView()
    
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
        
        levelup.name = "levelUp"
        levelup.anchorPoint = CGPoint(x: 0,y: 0)
        levelup.position = CGPoint(x:314,y: 700)
        levelup.size = CGSize(width: 100, height: 100)
        levelup.physicsBody?.categoryBitMask = 0
        levelup.physicsBody?.contactTestBitMask = 0
        levelup.physicsBody?.collisionBitMask = 0
        self.addChild(levelup)
        
        nameLabel.fontSize = 30
        nameLabel.fontColor = UIColor.red
        nameLabel.color = UIColor.white
        nameLabel.position = CGPoint(x: 207, y: 800)
        nameLabel.text = "キャラクター一覧"
        self.addChild(nameLabel)
        
        // Table setup
        gameTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableviewのxyは右上が(0,0)です。
        gameTableView.frame = CGRect(x:7,y:196,width:400,height:600)
        self.scene?.view?.addSubview(gameTableView)
        gameTableView.reloadData()
        
        
        self.getCharacterData()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let location = touch.location(in: self)
            
            if self.atPoint(location).name == "BackButton" {
                self.gotoTeamScene()
            }
            if self.atPoint(location).name == "levelUp" {
                self.addCharacter()
            }
        }
        
    }
    
    func gotoTeamScene() {
        
        //tableviewを消す
        gameTableView.removeFromSuperview()
        
        let Scene = TeamScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    func getCharacterData() {
        
        let characters:[Character] = Character.loadAll()
        
        print(characters)
        
        gameTableView.charactersArray = characters
        
        self.gameTableView.reloadData()
        
    }
    
    func addCharacter() {
        
        let character = Character.create(id: 1, name: "go", attack: 1, defence: 1, maxHp: 11, move: 1, side: .ally)
        //キャラクターをセーブする。
        character.save()
        
    }
    
    func gotoCharacterViewScene() {
        
        //tableviewを消す
        gameTableView.removeFromSuperview()
        
        let Scene = CharacterSortScene()
        Scene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)

        self.view?.presentScene(Scene, transition: transition)
        
    }
    
    class GameTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
        
        var charactersArray: [Character] = []
        
        override init(frame: CGRect, style: UITableView.Style) {
            
            super.init(frame: frame, style: style)
            self.delegate = self
            self.dataSource = self
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return charactersArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let nameLabel = UILabel(frame: CGRect(x: 140, y: 10, width: 200, height: 30))
            nameLabel.text = charactersArray[indexPath.row].Name
            nameLabel.font = UIFont.systemFont(ofSize: 24)
            cell.addSubview(nameLabel)
            
            let experieneceLevelLabel = UILabel(frame: CGRect(x: 140, y: 60, width: 70, height: 30))
            experieneceLevelLabel.text = "E-lv: \(charactersArray[indexPath.row].ExperienceLevel)"
            experieneceLevelLabel.font = UIFont.systemFont(ofSize: 18)
            cell.addSubview(experieneceLevelLabel)
            
            let developLevelLabel = UILabel(frame: CGRect(x: 220, y: 60, width: 70, height: 30))
            developLevelLabel.text = "D-lv: \(charactersArray[indexPath.row].DevelopLevel)"
            developLevelLabel.font = UIFont.systemFont(ofSize: 18)
            cell.addSubview(developLevelLabel)
            
            let characterImageview = UIImageView(frame: CGRect(x: 40, y: 20, width: 80, height: 80))
            cell.addSubview(characterImageview)
            
            let detailButton = UIButton(frame: CGRect(x: 320, y: 20, width: 60, height: 60))
            detailButton.backgroundColor = UIColor.red
            detailButton.setTitle("detail", for: .normal)
            detailButton.addTarget(self, action: #selector(touchButton(sender:)), for: .touchUpInside)
            cell.addSubview(detailButton)
            
            return cell
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            return 100
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //0スタートです。
            print("You selected cell #\(indexPath.row)!")
        }
        
        @objc func touchButton(sender: UIButton) {
            
            
            
        }
        
    }
    
    
}


