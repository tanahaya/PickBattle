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

class Character :Equatable {
    
    var Id:Int? //ステージごとで使用するID
    var CharacterId:Int? //キャラクターによって割り振られるID
    var Name:String = ""//名前
    var Image:String = ""//画像
    var Attack:Int?//攻撃力
    var Defence:Int?
    var MaxHp:Int?
    var Hp:Int?
    var Move:Int?
    var EnegyLevel:Int = 1
    var ExperienceLevel:Int = 1
    var DevelopLevel:Int = 1
    var Race:String = ""
    var PassiveSkill = ""
    var ActiveSkill0:Skill?
    var ActiveSkill1:Skill?
    var ActiveSkill2:Skill?
    var ActiveSkill3:Skill?
    var Attribution:String = ""
    var State:[String] = []
    var Routes:[[Int]] = []
    var Point:[Int] = []
    var Side:side = .ally //0なら味方、s1なら敵
    //移動を管理する。ここで宣言する必要があるかどうかは不明。
    var MoveFiled = Array2D<Int>(rows: BoardSizeXRow, columns: BoardSizeYColumn, repeatedValue: nil)
    
    init (Id:Int,Name:String,Attack:Int,Defence:Int,MaxHp:Int,Move:Int,Side:side) {
        
        self.Id = Id
        self.Name = Name
        self.Attack = Attack
        self.Defence = Defence
        self.MaxHp = MaxHp
        self.Hp = MaxHp
        self.Move = Move
        self.Side = Side
        
    }
    
    enum side:Int {
        
        case ally = 0,enemy //allyが0、enemyが1
        
    }
    
    //比較を可能にするためのコード
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.Id == rhs.Id
    }
    
}

