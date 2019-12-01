//
//  Broad.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/01.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation

let BoardSizeRow = 6 //行数、横列、0~5
let BoardSizeColumn = 8 //行数、縦に列、0~7

class Board {
    
    var cells: Array2D<CellState>
    
    init() {
        
        self.cells = Array2D<CellState>(rows: BoardSizeRow, columns: BoardSizeColumn, repeatedValue: .Empty)
        
        self.cells[0,0] = .Ally
        self.cells[1,1] = .Enemy
        
    }
    
    var description: String {
        
        var rows = Array<String>()
        
        for row in 0 ..< BoardSizeRow {
            
            var cells = Array<String>()
            
            for column in 0 ..< BoardSizeColumn {
                if let state = self.cells[row,column] {
                    cells.append(String(state.rawValue))
                }
            }
            
            let line:String = cells.joined(separator: "")
            rows.append(line)
            
        }
        
        return rows.reversed().joined(separator: "\n") //join("\n", rows.reverse())
        
    }
    
}





