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

class Character {
    
    var Id:Int?
    var Name:String = ""//名前
    var Image:String = ""//画像
    var Attack:Int?//攻撃力
    var Defence:Int?
    var MaxHp:Int?
    var Hp:Int?
    var Move:Int?
    var EnegyLevel:Int = 0
    var ExperienceLevel:Int = 1
    var DevelopLevel:Int = 1
    var Race:String = ""
    var PassiveSkill = ""
    var ActiveSkill = ""
    var Attribution:String = ""
    var State:[String] = []
    var Routes:[[Int]] = []
    var Point:[Int] = []
    var Side:Int? //0なら味方、1なら敵
    
    init (Id:Int,Name:String,Attack:Int,Defence:Int,MaxHp:Int,Move:Int) {
        
        self.Id = Id
        self.Name = Name
        self.Attack = Attack
        self.Defence = Defence
        self.MaxHp = MaxHp
        self.Move = Move
        
    }
    
}

