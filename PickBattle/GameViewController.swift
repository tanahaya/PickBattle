//
//  GameViewController.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/01.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        
        self.scene = GameScene()
        self.scene.size = CGSize(width: 414, height: 896)
        self.scene.scaleMode = .aspectFit
        
        skView.presentScene(self.scene)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}
