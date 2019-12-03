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
    let disksLayer = SKNode()//キャラクターの情報を表示する
    let routesLayer = SKNode()//ルートの情報を表示する
    
    //ボード上のキャラクター画像の管理をdiskNodesで行う
    var diskNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //ルートの情報を管理する
    var routeNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //ボードの情報を管理する。キャラクターとその状態
    var board:Board!
    
    let DiskImageNames = [CellState.Ally: "Ally1",CellState.Enemy: "Ally1"]
    let DiskCharactersImageNames = [1: "Ally1",2: "Ally1"]
    
    let routeImageNames = [1: "Route1",2: "Route2",3: "Route3",4: "Route4",5: "Route5",6: "Route6"]
    let EndPointImageNames = [1: "EndPoint1",2: "EndPoint2",3: "EndPoint3",4: "EndPoint4"]
    
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
        
        //anchorPointからの相対位置、routesLayerとdisLayerの左下端が(0,0)にするためにdisksLayerを配置
        let layerPosition = CGPoint(x: -SquareSize * CGFloat(BoardSizeXRow) / 2,y: -SquareSize * CGFloat(BoardSizeYColumn) / 2)
        
        self.routesLayer.position = layerPosition
        self.gameLayer.addChild(routesLayer)
        
        self.disksLayer.position = layerPosition
        self.gameLayer.addChild(disksLayer)
        
        
        self.initBoard()
        
        self.setAttackButton()  //アタックボタン
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        let gameLocation = touch!.location(in: self.gameLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            print("{\(row),\(column)}")
            
            if self.board.cells[row,column] == .Ally { //最初に触ったのが.allyの時
                
                let character = self.board.characterCells[row,column]
                
                for route in character!.Routes {
                    
                    let characterRow = route[0]
                    let characterColumn = route[1]
                    
                    if self.board.cells[characterRow,characterColumn] == .Route {
                        self.board.cells[characterRow,characterColumn] = .Empty
                    }
                    
                    if let prevRoute = self.routeNodes[characterRow,characterColumn] {
                        prevRoute.removeFromParent()
                    }
                    
                }
                
                character?.Routes = []
                character?.Routes.append([row,column])
                
                OperatingCharacter = character
                
            }
            
        }
        
        if self.gameLayer.atPoint(gameLocation).name == "AttackButton" {
            
            self.move()
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            
            if let state = self.board.cells[row,column] {
                
                if state == .Empty {
                    
                    if let LastRoute = OperatingCharacter?.Routes.last {
                        
                        if LastRoute != [row,column] {
                            
                            if LastRoute[0] - 1 == row || LastRoute[1] - 1 == column || LastRoute[0] + 1 == row || LastRoute[1] + 1 == column {
                                
                                if (OperatingCharacter?.Move)! >= (OperatingCharacter?.Routes.count)! {
                                    
                                    OperatingCharacter?.Routes.append([row,column])//ルートを追加します
                                    self.board.cells[row,column] = .Route
                                    
                                    //以下ルートを表示のためのコード
                                    let routes = OperatingCharacter?.Routes
                                                               
                                    if routes?.count  == 2 {
                                                                   
                                        let lastSquare = routes![1]
                                        let secondlastSquare = routes![0]
                                                                   
                                        if secondlastSquare[1] + 1 == lastSquare[1] {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: true, number: 1)
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 3)
                                        }
                                        if secondlastSquare[0] + 1 == lastSquare[0] {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: true, number: 2)
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 4)
                                        }
                                        if secondlastSquare[1] - 1 == lastSquare[1] {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: true, number: 3)
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 1)
                                        }
                                        if secondlastSquare[0] - 1 == lastSquare[0] {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: true, number: 4)
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 2)
                                        }
                                    } else if (routes?.count)! >= 3 {
                                                                   
                                        let lastSquare = routes![routes!.count - 1]
                                        let secondlastSquare = routes![routes!.count - 2]
                                        let thirdlastSquare = routes![routes!.count - 3]
                                        
                                        if secondlastSquare[1] + 1 == lastSquare[1] {
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 3)
                                        }
                                        if secondlastSquare[0] + 1 == lastSquare[0] {
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 4)
                                        }
                                        if secondlastSquare[1] - 1 == lastSquare[1] {
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 1)
                                        }
                                        if secondlastSquare[0] - 1 == lastSquare[0] {
                                            self.setRouteImage(row: lastSquare[0], column: lastSquare[1], PointFlag: true, number: 2)
                                        }
                                                                   
                                                                   
                                        if (thirdlastSquare[0] - 1 == secondlastSquare[0]  && secondlastSquare[1] + 1 == lastSquare[1]) || (thirdlastSquare[1] - 1 == secondlastSquare[1]  && secondlastSquare[0] + 1 == lastSquare[0]) {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: false, number: 1)
                                        }
                                        if (thirdlastSquare[1] - 1 == secondlastSquare[1]  && secondlastSquare[1] - 1 == lastSquare[1]) || (thirdlastSquare[1] + 1 == secondlastSquare[1]  && secondlastSquare[1] + 1 == lastSquare[1]) {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: false, number: 2)
                                        }
                                        if (thirdlastSquare[0] + 1 == secondlastSquare[0]  && secondlastSquare[1] + 1 == lastSquare[1]) || (thirdlastSquare[1] - 1 == secondlastSquare[1]  && secondlastSquare[0] - 1 == lastSquare[0]) {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: false, number: 3)
                                        }
                                        if (thirdlastSquare[0] - 1 == secondlastSquare[0]  && secondlastSquare[1] - 1 == lastSquare[1]) || (thirdlastSquare[1] + 1 == secondlastSquare[1]  && secondlastSquare[0] + 1 == lastSquare[0]) {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: false, number: 4)
                                        }
                                        if (thirdlastSquare[0] - 1 == secondlastSquare[0]  && secondlastSquare[0] - 1 == lastSquare[0]) || (thirdlastSquare[0] + 1 == secondlastSquare[0]  && secondlastSquare[0] + 1 == lastSquare[0]) {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: false, number: 5)
                                        }
                                        if (thirdlastSquare[0] + 1 == secondlastSquare[0]  && secondlastSquare[1] - 1 == lastSquare[1]) || (thirdlastSquare[1] + 1 == secondlastSquare[1]  && secondlastSquare[0] - 1 == lastSquare[0]) {
                                            self.setRouteImage(row: secondlastSquare[0], column: secondlastSquare[1], PointFlag: false, number: 6)
                                        }
                                                                   
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                //以下Enegyなど処理を書く
                
                
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
        
        var maxMove:Int = 0
        
        for ally in Allys {
            
            let routes = ally.Routes
            
            if maxMove < routes.count {
                maxMove = routes.count
            }
            
            if routes == [] {
                
            } else {
                
                let startRow = ally.Point[0]
                let startColumn = ally.Point[1]
                
                let GoalRow = (ally.Routes.last?[0])!
                let GoalColumn = (ally.Routes.last?[1])!
                
                print("routes:\(routes)")
                
                let node = diskNodes[startRow,startColumn]
                
                self.board.cells[startRow,startColumn] = .Empty
                self.board.characterCells[startRow,startColumn] = nil
                self.diskNodes[startRow,startColumn] = nil
                
                self.board.cells[GoalRow,GoalColumn] = .Ally
                self.board.characterCells[GoalRow,GoalColumn] = ally
                self.diskNodes[GoalRow,GoalColumn] = node
                ally.Point = [GoalRow,GoalColumn]
                 
                var SKActionArray:[SKAction] = []
                
                for routeNum in 0 ..< routes.count {
                    
                    if routeNum < routes.count - 1 {
                        
                        if routes[routeNum][0] < routes[routeNum + 1][0] {
                            
                            let action = SKAction.moveBy(x: 68, y: 0, duration: 0.5)
                            SKActionArray.append(action)
                            
                        } else if routes[routeNum][0] > routes[routeNum + 1][0] {
                            
                            let action = SKAction.moveBy(x: -68, y: 0, duration: 0.5)
                            SKActionArray.append(action)
                            
                        } else if routes[routeNum][1] < routes[routeNum + 1][1] {
                            
                            let action = SKAction.moveBy(x: 0, y: 68, duration: 0.5)
                            SKActionArray.append(action)
                            
                        } else if routes[routeNum][1] > routes[routeNum + 1][1] {
                            
                            let action = SKAction.moveBy(x: 0, y: -68, duration: 0.5)
                            SKActionArray.append(action)
                            
                        }
                        
                    }
                }
                
                node?.run(SKAction.sequence(SKActionArray))
                
            }
            
            ally.Routes = []//ルートの内容を初期化する。
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Double(maxMove - 1)) {
            
            for row in 0 ..< BoardSizeXRow { //.routeを.emptyに直す
                for column in 0 ..< BoardSizeYColumn {
                    if let state = self.board.cells[row,column] {
                        if state == .Route {
                            self.board.cells[row,column] = .Empty
                        }
                        
                        if let prevRoute = self.routeNodes[row,column] {
                            prevRoute.removeFromParent()
                        }
                        
                    }
                }
            }
            
            print(self.board.description)
            
        }
        
        
    }
    
    func setRouteImage(row:Int,column:Int,PointFlag:Bool,number:Int) {
        
        var ImageName:String = ""
        
        if PointFlag {
            ImageName = (EndPointImageNames[number])!
        } else {
            ImageName = (routeImageNames[number])!
        }
        
        if let prevNode = self.routeNodes[row,column] {
            prevNode.removeFromParent()
        }
                   
        let newNode = SKSpriteNode(imageNamed: ImageName)
        newNode.size = CGSize(width: SquareSize, height: SquareSize)
        newNode.position = self.convertPointOnLayer(row: row, column: column)
        
        self.routesLayer.addChild(newNode)
        self.routeNodes[row,column] = newNode
        
    }
    
    func setAttackButton() {
        
        AttackButton.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "AttackButton"), size: AttackButton.size)
        AttackButton.name = "AttackButton"
        AttackButton.physicsBody?.isDynamic = false//ぶつかったときに移動するかどうか =>しない
        AttackButton.position = CGPoint(x: 100,y: 320)//207,が中心に相当近い
        AttackButton.size = CGSize(width: 100.0, height: 50.0)
        self.gameLayer.addChild(AttackButton)
        
    }
    
    /// 盤上での座標をレイヤー上での座標に変換する
    func convertPointOnLayer(row: Int, column: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(row) * SquareSize + SquareSize / 2,
            y: CGFloat(column) * SquareSize + SquareSize / 2
        )
    }
    
    /// レイヤー上での座標を盤上での座標に変換する
    func convertPointOnBoard(point: CGPoint) -> (row: Int, column: Int)? {
        
        if 0 <= point.x && point.x < SquareSize * CGFloat(BoardSizeXRow) &&
            0 <= point.y && point.y < SquareSize * CGFloat(BoardSizeYColumn) {
            return (Int(point.x / SquareSize), Int(point.y / SquareSize))
        } else {
            return nil
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
