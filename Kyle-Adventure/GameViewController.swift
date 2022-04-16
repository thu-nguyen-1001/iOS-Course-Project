//
//  GameViewController.swift
//  Kyle-Adventure
//
//  Created by anh thu on 2022-03-27.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    if let view = self.view as! SKView? {
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        // Present the scene
        view.presentScene(scene)
      }
      view.ignoresSiblingOrder = true
      }
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
