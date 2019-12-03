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
    
    let SquareSize:CGFloat = 68.0 //マス目のサイズを用意
    
    var OperatingCharacter:Character? = nil
    
    var AttackButton = SKSpriteNode(imageNamed: "AttackButton")
    
    var Allys:[Character] = [] //味方を入れるための配列
    
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
        
        //アタックボタン
        AttackButton.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "AttackButton"), size: AttackButton.size)
        AttackButton.name = "AttackButton"
        AttackButton.physicsBody?.isDynamic = false//ぶつかったときに移動するかどうか =>しない
        AttackButton.position = CGPoint(x: 100,y: 320)//207,が中心に相当近い
        AttackButton.size = CGSize(width: 100.0, height: 50.0)
        self.gameLayer.addChild(AttackButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        let gameLocation = touch!.location(in: self.gameLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            print("{\(row),\(column)}")
            
            if self.board.cells[row,column] == .Ally { //最初に触ったのが.allyの時
                
                let character = self.board.characterCells[row,column]
                character?.Routes = []
                character?.Routes.append([row,column])
                
                OperatingCharacter = character
                
            }
            
        }
        
        if self.gameLayer.atPoint(gameLocation).name == "AttackButton" {
            
            self.move()
            
            self.AttackButton.alpha = 0.0
            
            print("AttackButton")
            print(self.board.description)
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            
            if let LastRoute = OperatingCharacter?.Routes.last {
                
                if LastRoute == [row,column] {
                    
                } else {
                    OperatingCharacter?.Routes.append([row,column])
                }
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let route:[[Int]] = OperatingCharacter?.Routes {
            
            print(route)
            OperatingCharacter = nil
            
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //盤面の初期化
    func initBoard() {
        
        self.board = Board()
        
        let oneA:Character = Character(Id: 1, Name: "one", Attack: 1, Defence: 1, MaxHp: 50, Move: 4)//とりあえずoneというキャラクターを用意
        self.addCharacterBoard(character: oneA, row: 1, column: 1)//キャラクターの情報と画像をBoardとdiskNodesに追加。
        self.Allys.append(oneA)
        
        print(self.board.description)
        
    }
    
    func addCharacterBoard(character:Character,row:Int,column:Int) {
        
        if let state = self.board.cells[row,column] {
            
            print(state)
            
            if state ==  .Empty {
                
                self.board.characterCells[row,column] = character
                character.Point = [row,column]
                self.board.cells[row,column] = .Ally
                
                let newCharacter = SKSpriteNode(imageNamed: DiskCharactersImageNames[character.Id!]! )
                newCharacter.size = CGSize(width: SquareSize, height: SquareSize)
                newCharacter.position = self.convertPointOnLayer(row: row, column: column)
                
                self.disksLayer.addChild(newCharacter)
                self.diskNodes[row,column] = newCharacter
                
            }
            
        }
        
    }
    
    func move() {
        
        for ally in Allys {
            
            let startRow = ally.Point[0]
            let startColumn = ally.Point[1]
            
            let GoalRow = (ally.Routes.last?[0])!
            let GoalColumn = (ally.Routes.last?[1])!
            
            let routes = ally.Routes
            print("routes:\(routes)")
            
            if routes == [] {
                
            } else {
                
                let node = diskNodes[startRow,startColumn]
                
                self.board.cells[startRow,startColumn] = .Empty
                self.board.characterCells[startRow,startColumn] = nil
                self.diskNodes[startRow,startColumn] = nil
                
                self.board.cells[GoalRow,GoalColumn] = .Ally
                self.board.characterCells[GoalRow,GoalColumn] = ally
                self.diskNodes[GoalRow,GoalColumn] = node
                 
                var SKActionArray:[SKAction] = []
                
                for routeNum in 0 ..< routes.count {
                    
                    if routeNum < routes.count - 1 {
                        if routes[routeNum][0] == routes[routeNum + 1][0] {
                            if routes[routeNum][1] < routes[routeNum + 1][1] {
                                
                                let action = SKAction.moveBy(x: 68, y: 0, duration: 1.0)
                                SKActionArray.append(action)
                                
                            } else if routes[routeNum][1] > routes[routeNum + 1][1] {
                                
                                let action = SKAction.moveBy(x: -68, y: 0, duration: 1.0)
                                SKActionArray.append(action)
                                
                            }
                        } else if routes[routeNum][1] == routes[routeNum + 1][1] {
                            if routes[routeNum][0] < routes[routeNum + 1][0] {
                                
                                let action = SKAction.moveBy(x: 0, y: 68, duration: 1.0)
                                SKActionArray.append(action)
                                
                            } else if routes[routeNum][0] > routes[routeNum + 1][0] {
                                
                                let action = SKAction.moveBy(x: 0, y: -68, duration: 1.0)
                                SKActionArray.append(action)
                                
                            }
                        }
                    }
                }
                
                node?.run(SKAction.sequence(SKActionArray))
                
            }
            
            ally.Routes = []//ルートの内容を初期化する。
            
        }
        
    }
    
    func moveCharacter(startRow:Int,startColumn:Int,routes:[[Int]]) {
        
        let node = diskNodes[startRow,startColumn]
        
        let GoalRow:Int = (routes.last?.first)!
        let GoalColumn:Int = (routes.last?.last)!
        
        if self.board.cells[startRow,startColumn] == .Ally {
            if let character = self.board.characterCells[startRow,startColumn] {
                
                print("routes:\(routes)")
                print("hello")
                
                self.board.cells[startRow,startColumn] = .Empty
                self.board.characterCells[startRow,startColumn] = nil
                self.diskNodes[startRow,startColumn] = nil
                
                self.board.cells[GoalRow,GoalColumn] = .Ally
                self.board.characterCells[GoalRow,GoalColumn] = character
                self.diskNodes[GoalRow,GoalColumn] = node
                
                
                var SKActionArray:[SKAction] = []
                
                for routeNum in 0 ..< routes.count {
                    
                    if routeNum < routes.count - 1 {
                        if routes[routeNum][0] == routes[routeNum + 1][0] {
                            if routes[routeNum][1] < routes[routeNum + 1][1] {
                                
                                let action = SKAction.moveBy(x: 68, y: 0, duration: 1.0)
                                SKActionArray.append(action)
                                
                            } else if routes[routeNum][1] > routes[routeNum + 1][1] {
                                
                                let action = SKAction.moveBy(x: -68, y: 0, duration: 1.0)
                                SKActionArray.append(action)
                                
                            }
                        } else if routes[routeNum][1] == routes[routeNum + 1][1] {
                            if routes[routeNum][0] < routes[routeNum + 1][0] {
                                
                                let action = SKAction.moveBy(x: 0, y: 68, duration: 1.0)
                                SKActionArray.append(action)
                                
                            } else if routes[routeNum][0] > routes[routeNum + 1][0] {
                                
                                let action = SKAction.moveBy(x: 0, y: -68, duration: 1.0)
                                SKActionArray.append(action)
                                
                            }
                        }
                    }
                }
                
                if let characterNode = self.diskNodes[startRow,startColumn] {
                    characterNode.run(SKAction.sequence(SKActionArray))
                }
                
                character.Routes = []//ルートの内容を初期化する。
                
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
