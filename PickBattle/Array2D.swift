//
//  File.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/01.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation

struct Array2D<T> {
    
    let rows:Int?//行数、横列、0~5
    let columns:Int?//列数、縦列、0~7
    
    //二次元配列の行優先順で格納した一次元配列
    private var array:[T?]
    
    
    init(rows:Int,columns:Int,repeatedValue:T? = nil) {
        self.rows = rows
        self.columns = columns
        self.array = [T?](repeating: repeatedValue, count: rows * columns)
    }
    
    subscript(row: Int,column:Int) -> T? {
        
        get {
            if row < 0  || self.rows! <= row || column < 0 || self.columns! <= column {
                return nil
            }
            let idx = row * self.columns! + column
            return array[idx]
        }
        
        set {
            
            self.array[row * self.columns! + column] = newValue
            
        }
        
    }
}
