//
//  Skill.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/04.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation

class Skill {
    
    var id:Int = 0
    var name:String = ""
    var magnification:Double = 1.0 //攻撃倍率
    var range:[[Int]] = []
    var skillType:skillType = .attack
    
    init(id:Int,name:String,magnification:Double,range:[[Int]],skillType:skillType) {
        
        self.id = id
        self.name = name
        self.magnification = magnification
        self.range = range
        self.skillType = skillType
        
    }
    
    enum skillType:Int { //attackが0、healが1
        
        case attack = 0,alert,heal
        
    }
    
    
}
