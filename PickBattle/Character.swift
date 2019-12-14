//
//  Character.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/02.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import RealmSwift

class Character :Object {
    
    @objc dynamic var Id:Int = 0
    @objc dynamic var CharacterId:Int = 0 //キャラクターによって割り振られるID
    @objc dynamic var Name:String = ""
    @objc dynamic var Image:String = ""
    @objc dynamic var Attack:Int = 0
    @objc dynamic var Defence:Int = 0
    @objc dynamic var MaxHp:Int = 1
    dynamic var Hp:Int = 1
    @objc dynamic var Move:Int = 0
    @objc dynamic var EnegyLevel:Int = 1
    @objc dynamic var ExperienceLevel:Int = 1
    @objc dynamic var DevelopLevel:Int = 1
    @objc dynamic var Race:String = ""
    @objc dynamic var PassiveSkill = ""
    @objc dynamic var ActiveSkill0:Skill?
    @objc dynamic var ActiveSkill1:Skill?
    @objc dynamic var ActiveSkill2:Skill?
    @objc dynamic var ActiveSkill3:Skill?
    @objc dynamic var Attribution:String = ""
    dynamic var State:[String] = []
    dynamic var Routes:[[Int]] = []
    dynamic var Point:[Int] = []
    dynamic var Side:side = .ally //0なら味方、s1なら敵
    //移動を管理する。ここで宣言する必要があるかどうかは不明。
    dynamic var MoveFiled = Array2D<Int>(rows: BoardSizeXRow, columns: BoardSizeYColumn, repeatedValue: nil)
    
    static let realm = try! Realm()
    
    enum side:Int {
        case ally = 0,enemy //allyが0、enemyが1
    }
    
    override static func primaryKey() -> String {
        return "Id"
    }
    
    static func lastId() -> Int {
        // isDoneの値を変更するとデータベース上の順序が変わるために、以下のようにしてidでソートして最大値を求めて+1して返す
        // 更新の必要がないなら、 realm.objects(ToDoModel).last で最後のデータのidを取得すればよい
        if let character = realm.objects(Character.self).sorted(byKeyPath: "Id", ascending: false).first {
            return character.Id + 1
        }else {
            return 1
        }
    }
    
    static func create(id:Int,name:String,attack:Int,defence:Int,maxHp:Int,move:Int,side:side) -> Character {
        
        let character = Character()
        
        character.Id = lastId()
        character.CharacterId = id
        character.Name = name
        character.Attack = attack
        character.Defence = defence
        character.MaxHp = maxHp
        character.Hp = maxHp
        character.Move = move
        character.Side = side
        
        return character
        
    }
    
    // ローカルのdefault.realmに作成したデータを保存するメソッド
    func save() {
        
        let realm = try! Realm()
        
        // writeでtransactionを生む
        try! realm.write {
            // モデルを保存
            realm.add(self)
        }
        
    }
    
    static func loadAll() -> [Character] {
        
        let realm = try! Realm()
        
        // Idでソートしながら、全件取得
        let characters = realm.objects(Character.self).sorted(byKeyPath: "Id", ascending: true)
        // 取得したデータを配列にいれる
        var ret: [Character] = []
        for character in characters {
            ret.append(character)
        }
         
        return ret
    }
    
}

