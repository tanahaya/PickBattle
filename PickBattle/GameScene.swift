//
//  GameScene.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/01.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let disksLayer = SKNode()
    
    //ボード上の画像の管理をdiskNodesで行う
    var diskNodes = Array2D<SKSpriteNode>(rows: BoardSizeRow, columns: BoardSizeColumn)
    //ボードの情報を管理する。
    var board:Board!
    
    let DiskImageNames = [CellState.Ally: "Ally1",CellState.Enemy: "Ally1"]
    let DiskCharactersImageNames = [1: "Ally1",2: "Ally1"]
    
    let SquareSize:CGFloat = 68.0//マス目のサイズを用意
    
    var OperatingCharacter:Character? = nil
    
    override func didMove(to view: SKView) {
        
        super.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        
        //背景を設定
        let background = SKSpriteNode(imageNamed: "Background")
        self.addChild(background)
        
        //gameLayerを追加
        self.addChild(self.gameLayer)
        
        //anchorPointからの相対位置、Boardの左下端が(0,0)にするためにdisksLayerを配置
        let layerPosition = CGPoint(x: -SquareSize * CGFloat(BoardSizeRow) / 2,y: -SquareSize * CGFloat(BoardSizeColumn) / 2)
        self.disksLayer.position = layerPosition
        self.gameLayer.addChild(disksLayer)
        
        self.initBoard()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            print("{\(row),\(column)}")
            
            if self.board.cells[row,column] == .Ally { //最初に触ったのが.allyの時
                
                let character = self.board.characterCells[row,column]
                character?.Route = []
                character?.Route.append([row,column])
                
                OperatingCharacter = character
                
            }
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            
            if OperatingCharacter?.Route.last == [row,column] {
                
            } else {
                OperatingCharacter?.Route.append([row,column])
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let route:[[Int]] = OperatingCharacter?.Route {
            
            print(route)
            OperatingCharacter = nil
            
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //盤面の初期化
    func initBoard() {
        
        self.board = Board()
        print(self.board.description)
        
        let oneA:Character = Character(Id: 1, Name: "one", Attack: 1, Defence: 1, MaxHp: 50, Move: 4)//とりあえずoneというキャラクターを用意
        self.addCharacterDiskNodes(character: oneA, row: 1, column: 1)//キャラクターの画像をdiskNodesに追加。
        
        //self.updateDiskNodes()
        
    }
    
    func addCharacterDiskNodes(character:Character,row:Int,column:Int) {
        
        if let state = self.board.cells[row,column] {
            
            print(state)
            
            if state ==  .Empty {
                
                self.board.characterCells[row,column] = character
                self.board.cells[row,column] = .Ally
                
                let newCharacter = SKSpriteNode(imageNamed: DiskCharactersImageNames[character.Id!]! )
                newCharacter.size = CGSize(width: SquareSize, height: SquareSize)
                newCharacter.position = self.convertPointOnLayer(row: row, column: column)
                
                self.disksLayer.addChild(newCharacter)
                self.diskNodes[row,column] = newCharacter
                
            }
            
        }
        
    }
    
    
    func updateDiskNodes(){
        
        for row in 0 ..< BoardSizeRow {
            for column in 0 ..< BoardSizeColumn {
                if let state = self.board.cells[row,column] {
                    
                    if let imageName = DiskImageNames[state] {
                        if let prevNode = self.diskNodes[row, column] {
                            if prevNode.userData?["state"] as! Int == state.rawValue {
                                // 変化が無いセルはスキップする
                                continue
                            }
                            // 古いノードを削除
                            prevNode.removeFromParent()
                        }
                        // 新しいノードをレイヤーに追加
                        let newNode = SKSpriteNode(imageNamed: imageName)
                        newNode.userData = ["state" : state.rawValue] as NSMutableDictionary
                        
                        newNode.size = CGSize(width: SquareSize, height: SquareSize)
                        newNode.position = self.convertPointOnLayer(row: row, column: column)
                        
                        self.disksLayer.addChild(newNode)
                        
                        self.diskNodes[row, column] = newNode
                        
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    /// 盤上での座標をレイヤー上での座標に変換する
    func convertPointOnLayer(row: Int, column: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * SquareSize + SquareSize / 2,
            y: CGFloat(row) * SquareSize + SquareSize / 2
        )
    }
    
    /// レイヤー上での座標を盤上での座標に変換する
    func convertPointOnBoard(point: CGPoint) -> (row: Int, column: Int)? {
        
        if 0 <= point.x && point.x < SquareSize * CGFloat(BoardSizeRow) &&
            0 <= point.y && point.y < SquareSize * CGFloat(BoardSizeColumn) {
            return (Int(point.y / SquareSize), Int(point.x / SquareSize))
        } else {
            return nil
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
