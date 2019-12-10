//
//  Skill.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/04.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation
import RealmSwift

class Skill:Object {
    
    dynamic var id:Int = 0
    dynamic var name:String = ""
    dynamic var magnification:Double = 1.0 //攻撃倍率
    dynamic var range:[[Int]] = []
    dynamic var skillType:skillType = .attack
    
    enum skillType:Int { //attackが0、healが1
        
        case attack = 0,alert,heal
        
    }
    
    
}
