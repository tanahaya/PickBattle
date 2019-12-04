//
//  Broad.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/01.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import Foundation

let BoardSizeXRow = 6
let BoardSizeYColumn = 8

class Board {
    
    var cells: Array2D<CellState>
    var characterCells: Array2D<Character>
    var itemCells: Array2D<CellItem>
    
    init() {
        
        self.cells = Array2D<CellState>(rows: BoardSizeXRow, columns: BoardSizeYColumn, repeatedValue: .Empty)
        self.characterCells = Array2D<Character>(rows: BoardSizeXRow, columns: BoardSizeYColumn, repeatedValue: nil)
        self.itemCells = Array2D<CellItem>(rows: BoardSizeXRow, columns: BoardSizeYColumn, repeatedValue: .Empty)
        
    }
    
    var description: String {
        
        var columns = Array<String>()
        
        for column in 0..<BoardSizeYColumn {
            var cells = Array<String>()
            
            for row in 0 ..< BoardSizeXRow {
                if let state = self.cells[row,column] {
                    cells.append(String(state.rawValue))
                }
            }
            
            let line:String = cells.joined(separator: "")
            columns.append(line)
        }
        
        return columns.reversed().joined(separator: "\n")
        
    }
    
    var itemDescription: String {
        
        var columns = Array<String>()
        
        for column in 0..<BoardSizeYColumn {
            var cells = Array<String>()
            
            for row in 0 ..< BoardSizeXRow {
                if let state = self.itemCells[row,column] {
                    cells.append(String(state.rawValue))
                }
            }
            
            let line:String = cells.joined(separator: "")
            columns.append(line)
        }
        
        return columns.reversed().joined(separator: "\n")
        
    }
    
}





