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
    
    //画像の管理をdiskNodesで行う
    var diskNodes = Array2D<SKSpriteNode>(rows: BoardSizeRow, columns: BoardSizeColumn)
    var board:Board!
    
    let DiskImageNames = [CellState.Ally: "Ally1",CellState.Enemy: "Ally1"]
    
    let SquareSize:CGFloat = 60.0//マス目のサイズを用意
    
    
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
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            print("{\(row),\(column)}")
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //盤面の初期化
    func initBoard() {
        
        self.board = Board()
        self.updateDiskNodes()
        
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
