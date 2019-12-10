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
    let itemLayer = SKNode()//アイテムの情報を表示する
    let routesLayer = SKNode()//ルートの情報を表示する
    let alertLayer = SKNode()//アラートの情報を表示する
    let effectLayer = SKNode()//エフェクトの情報を表示する
    
    //ボード上のキャラクター画像の管理をdiskNodesで行う
    var diskNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //ボード上のアイテム画像の管理をitemNodesで行う
    var itemNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //ルートの情報を管理する
    var routeNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //アラートの画像情報を管理する
    var alertNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //エフェクトの情報を管理する
    var effectNodes = Array2D<SKSpriteNode>(rows: BoardSizeXRow, columns: BoardSizeYColumn)
    //ボードの情報を管理する。キャラクターとその状態
    var board:Board!
    
    //キャラクターの画像を整理
    let DiskAllysImageNames = [1: "ally1",2: "ally2",3: "ally3"]
    let DiskEnemiesImageNames = [1: "enemy1",2: "enemy2",3: "enemy3"]
    
    //ルートの画像を整理
    let routeImageNames = [1: "Route1",2: "Route2",3: "Route3",4: "Route4",5: "Route5",6: "Route6"]
    let EndPointImageNames = [1: "EndPoint1",2: "EndPoint2",3: "EndPoint3",4: "EndPoint4"]
    
    //攻撃エフェクトの画像を整理
    let AttackEffectImageNames = [1:"AttackEffect1"]
    
    //マス目のサイズを用意
    let SquareSize:CGFloat = 68.0
    
    var OperatingCharacter:Character? = nil
    
    var AttackButton = SKSpriteNode(imageNamed: "AttackButton")
    
    //味方を入れるための配列
    var Allys:[Character] = []
    //敵を入れるための配列
    var Enemies:[Character] = []
    
    //ステージ管理用のuserdefaults
    let userDefaults = UserDefaults.standard
    var world = 0
    var stage = 0
    
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
        
        self.itemLayer.position = layerPosition
        self.gameLayer.addChild(itemLayer)
        
        self.disksLayer.position = layerPosition
        self.gameLayer.addChild(disksLayer)
        
        self.alertLayer.position = layerPosition
        self.gameLayer.addChild(alertLayer)
        
        self.effectLayer.position = layerPosition
        self.gameLayer.addChild(effectLayer)
        
        //ボードの初期化
        self.initBoard()
        
        //ターンを開始する
        self.turnStart()
        
        //アタックボタン
        self.setAttackButton()
        
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
            
            self.turnEnd()
            self.AttackButton.name = ""
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: self.disksLayer)
        
        if let (row,column) = self.convertPointOnBoard(point: location) {
            
            self.makeRoute(row: row, column: column)
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        OperatingCharacter = nil
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //盤面の初期化
    func initBoard() {
        
        self.getWorldStage()
        //ボードのインスタンスを生成
        self.board = Board()
        //キャラクターの追加
        self.SampleCharacter()
        //エネルギーを配置する
        self.setEnegy()
        
        print(self.board.description)
        
    }
    
    //ターンのはじめから味方の移動までの処理をまとめる
    func turnStart() {
        
        //時間的な処理を統一するためのタイマー
        // let waitTime:Double = 0.0
        
        //アラートの処理
        self.enemiesAlert()
        //エネルギーの生成
        self.setEnegy()
        
    }
    
    //AttackButtonを押してからターンエンドまでの処理をまとめる
    func turnEnd() {
        
        //時間的な処理を統一するためのタイマー
        var waitTime:Double = 0.0
        //移動
        waitTime = waitTime + self.allysMove(waitTime: waitTime)
        //攻撃
        waitTime = waitTime + self.allysAttack(waitTime: waitTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            
            //敵の死亡判定
            self.enemiesJudgeAlive()
            //アラートの削除
            self.deleteEnemiesAlert()
            //敵の移動と攻撃
            let wait = self.enemiesMoveAttack()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                
                //味方の死亡判定
                self.allysJudegeAlive()
                //味方のエネルギーレベルのリセット
                self.resetAllysEnegyLevel()
                //敵のエネルギーレベルとルートフィールドをリセット
                self.resetEnemiesEnegyLevel()
                //ターン開始を呼ぶ
                self.turnStart()
                //アタックボタンを有効化する
                self.enableAttackButton()
                
            }
            
        }
        
    }
    
    func makeRoute(row:Int,column:Int) {
        
        if let state = self.board.cells[row,column] {
            
            if state == .Empty {
                
                if let LastRoute = OperatingCharacter?.Routes.last {
                    
                    if LastRoute != [row,column] {
                        
                        if (LastRoute[0] - 1 == row && LastRoute[1] == column) || (LastRoute[1] - 1 == column && LastRoute[0] == row) || (LastRoute[0] + 1 == row && LastRoute[1] == column) || (LastRoute[1] + 1 == column && LastRoute[0] == row) {
                            
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
        }
        
    }
    
    func addCharacterBoard(character:Character,row:Int,column:Int) {
        
        if let state = self.board.cells[row,column] {
            
            if state ==  .Empty {
                
                if character.Side == .ally { //追加するキャラクターが味方の時の処理
                    
                    self.board.characterCells[row,column] = character
                    character.Point = [row,column]
                    self.board.cells[row,column] = .Ally
                    
                    let newCharacter = SKSpriteNode(imageNamed: DiskAllysImageNames[character.CharacterId]!)
                    newCharacter.size = CGSize(width: SquareSize, height: SquareSize)
                    newCharacter.position = self.convertPointOnLayer(row: row, column: column)
                    
                    self.disksLayer.addChild(newCharacter)
                    self.diskNodes[row,column] = newCharacter
                    
                } else if character.Side == .enemy { //追加するキャラクターが敵の時の処理
                    
                    self.board.characterCells[row,column] = character
                    character.Point = [row,column]
                    self.board.cells[row,column] = .Enemy
                    
                    let newCharacter = SKSpriteNode(imageNamed: DiskEnemiesImageNames[character.CharacterId]!)
                    newCharacter.size = CGSize(width: SquareSize, height: SquareSize)
                    newCharacter.position = self.convertPointOnLayer(row: row, column: column)
                    
                    self.disksLayer.addChild(newCharacter)
                    self.diskNodes[row,column] = newCharacter
                    
                }
                
            }
            
        }
        
    }
    
    func allysMove(waitTime:Double) -> (Double) {
        
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
                
                print("route:\(routes)")
                
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
                            
                            let action = SKAction.moveBy(x: 68, y: 0, duration: 0.3)
                            SKActionArray.append(action)
                            
                        } else if routes[routeNum][0] > routes[routeNum + 1][0] {
                            
                            let action = SKAction.moveBy(x: -68, y: 0, duration: 0.3)
                            SKActionArray.append(action)
                            
                        } else if routes[routeNum][1] < routes[routeNum + 1][1] {
                            
                            let action = SKAction.moveBy(x: 0, y: 68, duration: 0.3)
                            SKActionArray.append(action)
                            
                        } else if routes[routeNum][1] > routes[routeNum + 1][1] {
                            
                            let action = SKAction.moveBy(x: 0, y: -68, duration: 0.3)
                            SKActionArray.append(action)
                            
                        }
                        
                    }
                    
                    if self.board.itemCells[routes[routeNum][0],routes[routeNum][1]] == .Enegy {
                        
                        //画像を消す
                        self.board.itemCells[routes[routeNum][0],routes[routeNum][1]] = .Empty
                        if let prevEnegy = self.itemNodes[routes[routeNum][0],routes[routeNum][1]] {
                            prevEnegy.removeFromParent()
                        }
                        //味方のレベルを上昇させる
                        ally.EnegyLevel = ally.EnegyLevel + 1
                        print("\(ally.Name):\(ally.EnegyLevel)")
                        
                    }
                    
                }
                
                node?.run(SKAction.sequence(SKActionArray))
                
            }
            
            ally.Routes = []//ルートの内容を初期化する。
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 * Double(maxMove - 1)) {
            
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
            
        }
        
        return 0.3 * Double(maxMove - 1)
        
    }
    
    func allysAttack(waitTime:Double) -> (Double) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            
            var waitingTime = 0.0
            
            for ally in self.Allys {
                
                for i in 0 ..< ally.EnegyLevel {
                    
                    var attackSkill:Skill?
                    
                    switch i {
                        
                        case 0:
                            attackSkill = ally.ActiveSkill0
                        case 1:
                            attackSkill = ally.ActiveSkill1
                        case 2:
                            attackSkill = ally.ActiveSkill2
                        case 3:
                            attackSkill = ally.ActiveSkill3
                        default:
                            attackSkill = ally.ActiveSkill0
                        
                    }
                    
                    if attackSkill != nil {
                        
                        let attackRanges = attackSkill?.range
                        
                        if attackSkill?.skillType == .attack {
                            
                            for range in attackRanges! {
                                
                                let activeRange = [ally.Point[0] + range[0],ally.Point[1] + range[1]]
                                
                                if activeRange[0] >= 0 && activeRange[0] < 6 && activeRange[1] >= 0 && activeRange[1] < 8 {
                                    self.AttackEffect(row: activeRange[0], column: activeRange[1],wait: waitingTime)
                                }
                                
                                if self.board.cells[activeRange[0],activeRange[1]] == .Enemy {
                                    
                                    let enemy = self.board.characterCells[activeRange[0],activeRange[1]]
                                    self.damageEnemyHp(damage: Int(Double(ally.Attack) * attackSkill!.magnification), enemy: enemy!)
                                    
                                }
                            }
                            
                        } else if attackSkill?.skillType == .heal {
                            
                        }
                        
                        waitingTime = waitingTime + 0.5
                        
                    }
                    
                }
            }
            
        }
        
        var attackWaitTime = 0.0
        
        for ally in Allys {
            for _ in 0 ..< ally.EnegyLevel {
                
                attackWaitTime = attackWaitTime + 0.5
                
            }
        }
        
        return attackWaitTime
        
    }
    
    //敵のアラートをやります
    func enemiesAlert() {
        
        for enemy in Enemies {
            
            if let enemySkill =  enemy.ActiveSkill0 {
                if enemySkill.skillType == .alert {
                    
                    for range in enemySkill.range {
                        
                        print("alert: \(range[0]) ,\(range[1])")
                        
                        let redAlert = SKSpriteNode(color: UIColor.red, size: CGSize(width: SquareSize, height: SquareSize))
                        redAlert.alpha = 0.3
                        redAlert.position = self.convertPointOnLayer(row: range[0], column: range[1])
                        
                        self.alertLayer.addChild(redAlert)
                        self.alertNodes[range[0],range[1]] = redAlert
                        
                    }
                    
                }
            }
        }
        
    }
    
    func deleteEnemiesAlert(){
        
        for row in 0 ..< BoardSizeXRow { //.routeを.emptyに直す
            for column in 0 ..< BoardSizeYColumn {
                
                if let prevAlert = self.alertNodes[row,column] {
                    prevAlert.removeFromParent()
                }
                
            }
        }
        
    }
    
    //敵は個々に移動と攻撃を行うため処理を一緒にしております.
    func enemiesMoveAttack () -> (Double) {
        
        var waitingTime = 0.0
        
        for enemy in Enemies {
            
            if enemy.ActiveSkill0?.skillType == .attack {
                
                //最もダメージ場所を探す
                let rangeOfEnemy = self.judgeMoveRange(enemy: enemy, Ranges: [[enemy.Point[0],enemy.Point[1]]],Move: enemy.Move,first: true)
                
                var routeAndEnegy:[[Int]:Int] = [:]
                
                for i in 0 ..< rangeOfEnemy.count {
                    
                    let route = Array(self.judgeMoveRoute(Route: [rangeOfEnemy[i]], enemy: enemy).reversed())
                    //print("route: \(route)")
                    routeAndEnegy[route.last!] = self.numberOfEnegy(route: route)
                    
                }
                
                var maxPointCount = 0.0
                var maxPoint:[Int] = []
                
                for point in rangeOfEnemy {
                    
                    let enegyLevel = routeAndEnegy[point]
                    var pointCount = 0.0
                    
                    for level in 0 ..< enegyLevel! {
                        
                        var attackSkill:Skill?
                        
                        switch level {
                            
                            case 0:
                                attackSkill = enemy.ActiveSkill0
                            case 1:
                                attackSkill = enemy.ActiveSkill1
                            case 2:
                                attackSkill = enemy.ActiveSkill2
                            case 3:
                                attackSkill = enemy.ActiveSkill3
                            default:
                                attackSkill = enemy.ActiveSkill0
                            
                        }
                        
                        if attackSkill != nil {
                            
                            let attackRanges = attackSkill?.range
                            
                            for range in attackRanges! {
                                
                                let activeRange = [point[0] + range[0],point[1] + range[1]]
                                
                                if self.board.cells[activeRange[0],activeRange[1]] == .Ally {
                                    
                                    pointCount = pointCount + attackSkill!.magnification
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                    if maxPointCount <= pointCount {
                        
                        maxPointCount = pointCount
                        maxPoint = point
                        
                    }
                    
                }
                
                print("maxPoint :\(maxPoint) ,maxCount:\(maxPointCount)")
                
                //こっから実際の移動
                let praticalRoute = Array(self.judgeMoveRoute(Route: [maxPoint], enemy: enemy).reversed())
                
                let startRow = enemy.Point[0]
                let startColumn = enemy.Point[1]
                
                let GoalRow = maxPoint[0]
                let GoalColumn = maxPoint[1]
                
                print("route:\(praticalRoute)")
                
                let node = diskNodes[startRow,startColumn]
                
                self.board.cells[startRow,startColumn] = .Empty
                self.board.characterCells[startRow,startColumn] = nil
                self.diskNodes[startRow,startColumn] = nil
                
                self.board.cells[GoalRow,GoalColumn] = .Enemy
                self.board.characterCells[GoalRow,GoalColumn] = enemy
                self.diskNodes[GoalRow,GoalColumn] = node
                enemy.Point = [GoalRow,GoalColumn]
                
                var SKActionArray:[SKAction] = []
                let wait = SKAction.wait(forDuration: waitingTime)
                SKActionArray.append(wait)
                
                for routeNum in 0 ..< praticalRoute.count {
                    
                    if routeNum < praticalRoute.count - 1 {
                        
                        if praticalRoute[routeNum][0] < praticalRoute[routeNum + 1][0] {
                            
                            let action = SKAction.moveBy(x: 68, y: 0, duration: 0.3)
                            SKActionArray.append(action)
                            
                        } else if praticalRoute[routeNum][0] > praticalRoute[routeNum + 1][0] {
                            
                            let action = SKAction.moveBy(x: -68, y: 0, duration: 0.3)
                            SKActionArray.append(action)
                            
                        } else if praticalRoute[routeNum][1] < praticalRoute[routeNum + 1][1] {
                            
                            let action = SKAction.moveBy(x: 0, y: 68, duration: 0.3)
                            SKActionArray.append(action)
                            
                        } else if praticalRoute[routeNum][1] > praticalRoute[routeNum + 1][1] {
                            
                            let action = SKAction.moveBy(x: 0, y: -68, duration: 0.3)
                            SKActionArray.append(action)
                            
                        }
                        
                    }
                    
                    if self.board.itemCells[praticalRoute[routeNum][0],praticalRoute[routeNum][1]] == .Enegy {
                        
                        //画像を消す
                        self.board.itemCells[praticalRoute[routeNum][0],praticalRoute[routeNum][1]] = .Empty
                        if let prevEnegy = self.itemNodes[praticalRoute[routeNum][0],praticalRoute[routeNum][1]] {
                            prevEnegy.removeFromParent()
                        }
                        
                        //味方のレベルを上昇させる
                        enemy.EnegyLevel = enemy.EnegyLevel + 1
                        print("\(enemy.Name):\(enemy.EnegyLevel)")
                        
                    }
                    
                }
                
                node?.run(SKAction.sequence(SKActionArray))
                
                waitingTime = waitingTime + 0.3 * Double(praticalRoute.count - 1)
                
                //ここから攻撃
                DispatchQueue.main.asyncAfter(deadline: .now() + waitingTime) {
                    
                    var waitTime = 0.0
                    
                    for i in 0 ..< enemy.EnegyLevel {
                        
                        var attackSkill:Skill?
                        
                        switch i {
                            
                            case 0:
                                attackSkill = enemy.ActiveSkill0
                            case 1:
                                attackSkill = enemy.ActiveSkill1
                            case 2:
                                attackSkill = enemy.ActiveSkill2
                            case 3:
                                attackSkill = enemy.ActiveSkill3
                            default:
                                attackSkill = enemy.ActiveSkill0
                            
                        }
                        
                        if attackSkill != nil {
                            
                            let attackRanges = attackSkill?.range
                            
                            if attackSkill?.skillType == .attack {
                                
                                for range in attackRanges! {
                                    
                                    let activeRange = [enemy.Point[0] + range[0],enemy.Point[1] + range[1]]
                                    
                                    if activeRange[0] >= 0 && activeRange[0] < 6 && activeRange[1] >= 0 && activeRange[1] < 8 {
                                        self.AttackEffect(row: activeRange[0], column: activeRange[1],wait: waitTime)
                                    }
                                    
                                    if self.board.cells[activeRange[0],activeRange[1]] == .Ally {
                                        
                                        let ally = self.board.characterCells[activeRange[0],activeRange[1]]
                                        self.damageAllyHp(damage: Int(Double(enemy.Attack) * attackSkill!.magnification), ally: ally!)
                                        
                                    }
                                }
                                
                            } else if attackSkill?.skillType == .heal {
                                
                            }
                            
                            waitTime = waitTime + 0.5
                            
                        }
                        
                    }
                    
                }
                
                
                
            } else if enemy.ActiveSkill0?.skillType == .heal {
                
            } else if enemy.ActiveSkill0?.skillType == .alert {
                
                let attackRanges = enemy.ActiveSkill0?.range
                
                for range in attackRanges! {
                    
                    if range[0] >= 0 && range[0] < 6 && range[1] >= 0 && range[1] < 8 {
                        self.AttackEffect(row: range[0], column: range[1],wait: waitingTime)
                    }
                    
                    if self.board.cells[range[0],range[1]] == .Ally {
                        
                        let ally = self.board.characterCells[range[0],range[1]]
                        self.damageAllyHp(damage: Int(Double(enemy.Attack) * enemy.ActiveSkill0!.magnification), ally: ally!)
                        
                    }
                }
            }
            
        }
        
        return waitingTime
        
    }
    
    func judgeMoveRange(enemy:Character,Ranges:[[Int]],Move:Int,first:Bool) -> [[Int]] {
        
        let MovedCount:Int = Move - 1
        var newRange:[[Int]] = []
        
        if first {
            for range in Ranges {
                enemy.MoveFiled[range[0],range[1]] = Move
            }
        }
        
        if Move > 0 {
            
            for range in Ranges {
                
                let upRange = [range[0],range[1] + 1]
                let downRange = [range[0],range[1] - 1]
                let rightRange = [range[0] + 1,range[1]]
                let leftRange = [range[0] - 1,range[1]]
                
                if enemy.MoveFiled[upRange[0],upRange[1]] == nil && self.board.cells[upRange[0],upRange[1]] == .Empty && upRange[0] >= 0 && upRange[0] < 6  && upRange[1] >= 0 && upRange[1] < 8 {
                    enemy.MoveFiled[upRange[0],upRange[1]] = MovedCount
                    newRange.append(upRange)
                }
                if enemy.MoveFiled[rightRange[0],rightRange[1]] == nil && self.board.cells[rightRange[0],rightRange[1]] == .Empty && rightRange[0] >= 0 && rightRange[0] < 6  && rightRange[1] >= 0 && rightRange[1] < 8 {
                    enemy.MoveFiled[rightRange[0],rightRange[1]] = MovedCount
                    newRange.append(rightRange)
                }
                if enemy.MoveFiled[downRange[0],downRange[1]] == nil  && self.board.cells[downRange[0],downRange[1]] == .Empty && downRange[0] >= 0 && downRange[0] < 6  && downRange[1] >= 0 && downRange[1] < 8 {
                    enemy.MoveFiled[downRange[0],downRange[1]] = MovedCount
                    newRange.append(downRange)
                }
                if enemy.MoveFiled[leftRange[0],leftRange[1]] == nil && self.board.cells[leftRange[0],leftRange[1]] == .Empty && leftRange[0] >= 0 && leftRange[0] < 6  && leftRange[1] >= 0 && leftRange[1] < 8 {
                    enemy.MoveFiled[leftRange[0],leftRange[1]] = MovedCount
                    newRange.append(leftRange)
                }
                
                
            }
            
            return newRange + self.judgeMoveRange(enemy: enemy, Ranges: newRange, Move: MovedCount,first: false)
            
        } else {
            
            return []
            
        }
        
    }
    
    func judgeMoveRoute(Route:[[Int]],enemy:Character) -> [[Int]] {
        
        var makingRoute:[[Int]] = Route
        
        var startMove = enemy.MoveFiled[Route.last![0],Route.last![1]]
        
        let range = [Route.last![0],Route.last![1]]
        
        let upRange = [range[0],range[1] + 1]
        let rightRange = [range[0] + 1,range[1]]
        let downRange = [range[0],range[1] - 1]
        let leftRange = [range[0] - 1,range[1]]
        
        var nextRange:[Int] = []
        
        startMove = startMove! + 1
        
        if startMove == enemy.MoveFiled[upRange[0],upRange[1]] {
            nextRange = upRange
        } else if startMove == enemy.MoveFiled[rightRange[0],rightRange[1]] {
            nextRange = rightRange
        } else if startMove == enemy.MoveFiled[downRange[0],downRange[1]] {
            nextRange = downRange
        } else if startMove == enemy.MoveFiled[leftRange[0],leftRange[1]] {
            nextRange = leftRange
        }
        
        makingRoute.append(nextRange)
        
        if nextRange == enemy.Point {
            
            return makingRoute
            
        } else {
            return self.judgeMoveRoute(Route: makingRoute, enemy: enemy)
        }
        
    }
    
    func numberOfEnegy(route:[[Int]]) -> Int {
        
        var count = 1
        
        for point in route {
            if self.board.itemCells[point[0],point[1]] == .Enegy {
                count = count + 1
            }
        }
        
        return count
        
    }
    
    //攻撃のエフェクトを追加する。
    func AttackEffect(row:Int,column:Int,wait:Double) {
        
        let newEffect = SKSpriteNode(imageNamed:  AttackEffectImageNames[1]!)
        newEffect.size = CGSize(width: SquareSize, height: SquareSize)
        newEffect.position = self.convertPointOnLayer(row: row, column: column)
        newEffect.alpha = 0.0
        
        self.effectLayer.addChild(newEffect)
        self.effectNodes[row,column] = newEffect
        
        let firstWait = SKAction.wait(forDuration: wait)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let wait = SKAction.wait(forDuration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        
        newEffect.run(SKAction.sequence([firstWait,fadeIn,wait,fadeOut,remove]))
        
    }
    
    //敵のhpを減らすメソッド
    func damageEnemyHp(damage:Int,enemy:Character) {
        
        print("beforeHp:\(enemy.Hp)")
        enemy.Hp = enemy.Hp - damage
        print("afterHp:\(enemy.Hp)")
        
    }
    
    //味方のhpを減らすメソッド
    func damageAllyHp(damage:Int,ally:Character) {
        
        print("beforeHp:\(ally.Hp)")
        ally.Hp = ally.Hp - damage
        print("afterHp:\(ally.Hp)")
        
    }
    
    //生死を判定する。
    func enemiesJudgeAlive() {
        
        for enemy in Enemies {
            
            if enemy.Hp <= 0 {
                
                //敵の死亡処理
                let point = [enemy.Point[0],enemy.Point[1]]
                
                //画像の削除
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                fadeOut.timingMode = .easeIn
                let remove = SKAction.removeFromParent()
                
                let enemyImage = self.diskNodes[point[0],point[1]]
                enemyImage?.run(SKAction.sequence([fadeOut,remove]))
                
                //情報の削除
                self.board.cells[point[0],point[1]] = .Empty
                self.board.characterCells[point[0],point[1]] = nil
                
                //敵の配列から排除する
                if let i = Enemies.firstIndex(of: enemy) {
                    Enemies.remove(at: i)
                }
                
            }
            
        }
    }
    
    func allysJudegeAlive() {
        
        for ally in Allys {
            
            if ally.Hp <= 0 {
                
                //敵の死亡処理
                let point = [ally.Point[0],ally.Point[1]]
                
                //画像の削除
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                fadeOut.timingMode = .easeIn
                let remove = SKAction.removeFromParent()
                
                let allyImage = self.diskNodes[point[0],point[1]]
                allyImage?.run(SKAction.sequence([fadeOut,remove]))
                
                //情報の削除
                self.board.cells[point[0],point[1]] = .Empty
                self.board.characterCells[point[0],point[1]] = nil
                
                //敵の配列から排除する
                if let i = Allys.firstIndex(of: ally) {
                    Allys.remove(at: i)
                }
                
            }
            
            
        }
        
    }
    
    func enableAttackButton() {
        AttackButton.name = "AttackButton"
    }
    
    func resetAllysEnegyLevel() {
        
        for ally in Allys {
            ally.EnegyLevel = 1
        }
        
    }
    
    func  resetEnemiesEnegyLevel() {
        
        for enemy in Enemies {
            
            enemy.EnegyLevel = 1
            
            for row in 0 ..< BoardSizeXRow { //.routeを.emptyに直す
                for column in 0 ..< BoardSizeYColumn {
                    
                    enemy.MoveFiled[row,column] = nil
                    
                }
            }
            
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
    
    func setEnegy() {
        
        var numberOfEnegy:Int = 0
        
        for row in 0 ..< BoardSizeXRow { //.routeを.emptyに直す
            for column in 0 ..< BoardSizeYColumn {
                
                if self.board.itemCells[row,column] == .Enegy {
                    numberOfEnegy = numberOfEnegy + 1
                }
                
            }
        }
        
        var addNumberOfEnegy = 6 - numberOfEnegy
        
        while addNumberOfEnegy > 0 {
            
            let enegyRow:Int = Int.random(in: 0..<6)
            let enegyColumn:Int = Int.random(in: 0..<8)
            
            if self.board.cells[enegyRow,enegyColumn] == .Empty && self.board.itemCells[enegyRow,enegyColumn] == .Empty {
                
                let newEnegy = SKSpriteNode(imageNamed: "enegy")
                newEnegy.size = CGSize(width: SquareSize, height: SquareSize)
                newEnegy.position = self.convertPointOnLayer(row: enegyRow, column: enegyColumn)
                
                self.board.itemCells[enegyRow,enegyColumn] = .Enegy
                self.itemLayer.addChild(newEnegy)
                self.itemNodes[enegyRow,enegyColumn] = newEnegy
                
                addNumberOfEnegy = addNumberOfEnegy - 1
                
            }
            
        }
        
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
    
    func getWorldStage() {
        
        //ワールドとステージを取得する
        world = userDefaults.integer(forKey: "world")
        stage = userDefaults.integer(forKey: "stage")
        print("\(world)")
        
    }
    
    func SampleCharacter() {
        
        //味方の生成
        let oneA:Character = Character.create(id: 1, name: "oneA", attack: 5, defence: 1, maxHp: 50, move: 4, side: .ally)
        //oneAというキャラクターを用意
        oneA.ActiveSkill0 = Skill()
        oneA.ActiveSkill0!.id = 1
        oneA.ActiveSkill0!.name = ""
        oneA.ActiveSkill0!.magnification = 1.0
        oneA.ActiveSkill0!.range =  [[1,1],[1,0],[1,-1]]
        oneA.ActiveSkill0!.skillType = .attack
        oneA.ActiveSkill1 = Skill()
        oneA.ActiveSkill1!.id = 2
        oneA.ActiveSkill1!.name = ""
        oneA.ActiveSkill1!.magnification = 1.0
        oneA.ActiveSkill1!.range =  [[-1,1],[-1,0],[-1,0]]
        oneA.ActiveSkill1!.skillType = .attack
        oneA.ActiveSkill2 = Skill()
        oneA.ActiveSkill2!.id = 3
        oneA.ActiveSkill2!.name = ""
        oneA.ActiveSkill2!.magnification = 1.0
        oneA.ActiveSkill2!.range =  [[0,1],[0,-1]]
        oneA.ActiveSkill2!.skillType = .attack
        oneA.ActiveSkill3 = Skill()
        oneA.ActiveSkill3!.id = 4
        oneA.ActiveSkill3!.name = ""
        oneA.ActiveSkill3!.magnification = 1.0
        oneA.ActiveSkill3!.range =  [[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7]]
        oneA.ActiveSkill3!.skillType = .attack
        self.addCharacterBoard(character: oneA, row: 2, column: 4)//キャラクターの情報と画像をBoardとdiskNodesに追加。
        self.Allys.append(oneA)
        
        let twoB:Character = Character.create(id: 2,name: "twoB", attack: 5, defence: 1, maxHp: 50, move: 5, side: .ally)//twoというキャラクターを用意
        twoB.ActiveSkill0 = Skill()
        twoB.ActiveSkill0!.id = 5
        twoB.ActiveSkill0!.name = ""
        twoB.ActiveSkill0!.magnification = 1.0
        twoB.ActiveSkill0!.range =  [[1,0],[2,0],[3,0],[4,0],[5,0]]
        twoB.ActiveSkill0!.skillType = .attack
        twoB.ActiveSkill1 = Skill()
        twoB.ActiveSkill1!.id = 6
        twoB.ActiveSkill1!.name = ""
        twoB.ActiveSkill1!.magnification = 1.0
        twoB.ActiveSkill1!.range =  [[-1,0],[-2,0],[-3,0],[-4,0],[-5,0]]
        twoB.ActiveSkill1!.skillType = .attack
        twoB.ActiveSkill2 = Skill()
        twoB.ActiveSkill2!.id = 7
        twoB.ActiveSkill2!.name = ""
        twoB.ActiveSkill2!.magnification = 1.0
        twoB.ActiveSkill2!.range =  [[1,1],[0,1],[-1,1],[1,-1],[0,-1],[-1,-1]]
        twoB.ActiveSkill2!.skillType = .attack
        twoB.ActiveSkill3 = Skill()
        twoB.ActiveSkill3!.id = 8
        twoB.ActiveSkill3!.name = ""
        twoB.ActiveSkill3!.magnification = 1.0
        twoB.ActiveSkill3!.range =  [[1,0],[2,0],[3,0],[4,0],[5,0],[-1,0],[-2,0],[-3,0],[-4,0],[-5,0]]
        twoB.ActiveSkill3!.skillType = .attack
        self.addCharacterBoard(character: twoB, row: 3, column: 4)//キャラクターの情報と画像をBoardとdiskNodesに追加。
        self.Allys.append(twoB)
        
        let threeC:Character = Character.create(id: 3,name: "threeC", attack: 5, defence: 1, maxHp: 50, move: 6, side: .ally)//threeというキャラクターを用意
        threeC.ActiveSkill0 = Skill()
        threeC.ActiveSkill0!.id = 9
        threeC.ActiveSkill0!.name = ""
        threeC.ActiveSkill0!.magnification = 1.0
        threeC.ActiveSkill0!.range =  [[1,1],[1,0],[1,-1]]
        threeC.ActiveSkill0!.skillType = .attack
        threeC.ActiveSkill1 = Skill()
        threeC.ActiveSkill1!.id = 10
        threeC.ActiveSkill1!.name = ""
        threeC.ActiveSkill1!.magnification = 1.0
        threeC.ActiveSkill1!.range =  [[0,1],[0,-1]]
        threeC.ActiveSkill1!.skillType = .attack
        threeC.ActiveSkill2 = Skill()
        threeC.ActiveSkill2!.id = 11
        threeC.ActiveSkill2!.name = ""
        threeC.ActiveSkill2!.magnification = 1.0
        threeC.ActiveSkill2!.range =  [[-1,-1],[-1,0],[-1,1]]
        threeC.ActiveSkill2!.skillType = .attack
        threeC.ActiveSkill3 = Skill()
        threeC.ActiveSkill3!.id = 12
        threeC.ActiveSkill3!.name = ""
        threeC.ActiveSkill3!.magnification = 1.0
        threeC.ActiveSkill3!.range = [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]
        threeC.ActiveSkill3!.skillType = .attack
        self.addCharacterBoard(character: threeC, row: 2, column: 3)//キャラクターの情報と画像をBoardとdiskNodesに追加。
        self.Allys.append(threeC)
        
        //敵の生成
        let firstA:Character = Character.create(id: 1,name: "firstA", attack: 5, defence: 1, maxHp: 50, move: 3, side: .enemy)
        firstA.ActiveSkill0 = Skill()
        firstA.ActiveSkill0!.id = 1
        firstA.ActiveSkill0!.name = ""
        firstA.ActiveSkill0!.magnification = 1.0
        firstA.ActiveSkill0!.range =  [[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7]]
        firstA.ActiveSkill0!.skillType = .attack
        firstA.ActiveSkill1 = Skill()
        firstA.ActiveSkill1!.id = 2
        firstA.ActiveSkill1!.name = ""
        firstA.ActiveSkill1!.magnification = 1.5
        firstA.ActiveSkill1!.range =   [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]]
        firstA.ActiveSkill1!.skillType = .attack
        self.addCharacterBoard(character: firstA, row: 1, column: 6)
        self.Enemies.append(firstA)
        
        let secondB:Character = Character.create(id: 2,name: "secondB", attack: 5, defence: 1, maxHp: 50, move: 3, side: .enemy)
        secondB.ActiveSkill0 = Skill()
        secondB.ActiveSkill0!.id = 1
        secondB.ActiveSkill0!.name = ""
        secondB.ActiveSkill0!.magnification = 2.0
        secondB.ActiveSkill0!.range =  [[1,0],[2,0],[3,0],[4,0],[5,0],[-1,0],[-2,0],[-3,0],[-4,0],[-5,0]]
        secondB.ActiveSkill0!.skillType = .attack
        self.addCharacterBoard(character: secondB, row: 2, column: 6)
        self.Enemies.append(secondB)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
