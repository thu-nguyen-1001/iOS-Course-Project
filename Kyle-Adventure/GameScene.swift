//
//  GameScene.swift
//  Kyle-Adventure
//
//  Created by anh thu on 2022-03-27.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let TotalTreasure = 6
    let playerSpeed: CGFloat = 150.0
    let monsterSpeed: CGFloat = 10.0

    private var runUpFrames : [SKTexture] = []
    private var runDownFrames : [SKTexture] = []
    private var runLeftFrames : [SKTexture] = []
    private var runRightFrames : [SKTexture] = []
    var player: SKSpriteNode!
    var myCamera: SKNode!
    
    private var mushroomFrames : [SKTexture] = []
    var mushrooms: [SKSpriteNode] = []

    private var turtleMoveLeftFrames : [SKTexture] = []
    private var turtleMoveRightFrames : [SKTexture] = []
    var turtles: [SKSpriteNode] = []

    var golds: [SKSpriteNode] = []
    var treasures: [SKSpriteNode] = []

    var numberOfTreasure = 0
    var goldAmount = 0

    var lastTouch: CGPoint? = nil

    override func didMove(to view: SKView) {
        backgroundColor = .blue
        // Set up physics world's contact delegate
        physicsWorld.contactDelegate = self
        // setup player
        self.player = SKSpriteNode()
        self.player = childNode(withName: "player")! as? SKSpriteNode
        buildPlayer()
        listener = player

        // setup camera
        self.myCamera = SKNode()
        self.myCamera? = childNode(withName: "camera")!
        updateCamera();
        
        for child in self.children {
        // setup items
            if child.name == "gold" {
                if let child = child as? SKSpriteNode {
                    golds.append(child)
                }
            }
            if child.name == "treasure-box" {
                if let child = child as? SKSpriteNode {
                    treasures.append(child)
                }
            }
        // setup monsters
            if child.name == "mushroom" {
                if let child = child as? SKSpriteNode {
                    mushrooms.append(child)
                }
            }
            if child.name == "turtle" {
                if let child = child as? SKSpriteNode {
                    turtles.append(child)
                }
            }
        }
        buildMonster()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }

    fileprivate func handleTouches(_ touches: Set<UITouch>) {
        lastTouch = touches.first?.location(in: self)
    }

    override func didSimulatePhysics() {
      if player != nil {
        updatePlayer()
        updateMonster()
      }
    }
    
    // Determines whether the player's position should be updated
    fileprivate func shouldMove(currentPosition: CGPoint,
                                touchPosition: CGPoint) -> Bool {
        guard let player = player else { return false }
        return abs(currentPosition.x - touchPosition.x) > player.frame.width / 2 ||
               abs(currentPosition.y - touchPosition.y) > player.frame.height / 2
    }
    
    fileprivate func updatePlayer() {
        guard let player = player,
              let touch = lastTouch
        else { return }
        let currentPosition = player.position
        if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
            updatePlayerPosition(for: player, to: touch, speed: playerSpeed)
            updateCamera()
        } else {
            player.physicsBody?.isResting = true
            playerMoveEnded()
        }
    }
    
    fileprivate func updateMonster() {
        guard let player = player else { return }
        let targetPosition = player.position

        for mushroom in mushrooms {
            updateMushroomPosition(for: mushroom, to: targetPosition, speed: monsterSpeed)
        }
        for turtle in turtles {
            updateTurtlePosition(for: turtle, to: targetPosition, speed: monsterSpeed)
        }
    }
    
    fileprivate func updateCamera() {
        guard let player = player else { return }
        camera?.position = player.position
    }
    
    fileprivate func updatePlayerPosition(for sprite: SKSpriteNode,
                                          to target: CGPoint, speed: CGFloat) {
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                       currentPosition.x - target.x)
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        if sprite.action(forKey: "playerRunning") == nil {
            if abs(velocityY) > abs(velocityX) {
                if velocityY > 0 {
                    animatePlayer(frames: runUpFrames)
                } else {
                    animatePlayer(frames: runDownFrames)
                }
            } else {
                if velocityX > 0 {
                    animatePlayer(frames: runRightFrames)
                } else {
                    animatePlayer(frames: runLeftFrames)
                }
            }
        }
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
    }
  
    fileprivate func updateMushroomPosition(for sprite: SKSpriteNode,
                                    to target: CGPoint, speed: CGFloat) {
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                       currentPosition.x - target.x)
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        if sprite.action(forKey: "monsterMoving") == nil {
            sprite.run(SKAction.repeatForever(
                SKAction.animate(with: mushroomFrames, timePerFrame: 0.5, resize: false, restore: true)),
                       withKey: "monsterMoving")
        }
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
    }
    
    fileprivate func updateTurtlePosition(for sprite: SKSpriteNode,
                                    to target: CGPoint, speed: CGFloat) {
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                       currentPosition.x - target.x)
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
            if velocityX > 0 {
                if sprite.action(forKey: "monsterMovingLeft") == nil {
                sprite.run(SKAction.repeatForever(
                    SKAction.animate(with: turtleMoveRightFrames, timePerFrame: 0.5, resize: false, restore: true)),
                           withKey: "monsterMovingLeft")
                }
            } else {
                if sprite.action(forKey: "monsterMovingRight") == nil {
                sprite.run(SKAction.repeatForever(
                    SKAction.animate(with: turtleMoveLeftFrames, timePerFrame: 0.5, resize: false, restore: true)),
                           withKey: "monsterMovingRight")
                }
            }
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
    }
  
    fileprivate func buildMonster() {
        // build mushroom
        let mushroomAtlas = SKTextureAtlas(named: "mushroom")
        for i in 0...1 {
            let mushroomTexture = "mushroom-\(i)"
            mushroomFrames.append(mushroomAtlas.textureNamed(mushroomTexture))
        }
        // build turtle
        let turtleAtlas = SKTextureAtlas(named: "turtle")
        for i in 0...1 {
            let turtleTexture = "turtle-\(i)"
            turtleMoveLeftFrames.append(turtleAtlas.textureNamed(turtleTexture))
        }
        for i in 2...3 {
            let turtleTexture = "turtle-\(i)"
            turtleMoveRightFrames.append(turtleAtlas.textureNamed(turtleTexture))
        }
    }
    
    fileprivate func buildPlayer() {
        let playerAnimatedAtlas = SKTextureAtlas(named: "player")
        
        for i in 0...2 {
            let playerTextureName = "player-\(i)"
            runDownFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        for i in 3...5 {
            let playerTextureName = "player-\(i)"
            runLeftFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        for i in 6...8 {
            let playerTextureName = "player-\(i)"
            runUpFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        for i in 9...11 {
            let playerTextureName = "player-\(i)"
            runRightFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
    }
    
    func animatePlayer(frames: [SKTexture]) {
        player.run(SKAction.repeatForever(
            SKAction.animate(with: frames, timePerFrame: 0.1, resize: false, restore: true)),
                   withKey: "playerRunning")
    }
    
    func playerMoveEnded() {
        player.removeAllActions()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
    
        // lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // contact between the two nodes
        if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == mushrooms[0].physicsBody?.categoryBitMask {
            // Player & Mushroom
            gameOver(false)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == golds[0].physicsBody?.categoryBitMask {
            // Player & Gold
            secondBody.node?.removeFromParent()
            goldAmount += 1
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == treasures[0].physicsBody?.categoryBitMask {
            // Player & Treasure
            numberOfTreasure += 1
            secondBody.node?.removeFromParent()
            if numberOfTreasure == 28 {
                gameOver(true)
            }
        }
    }

    fileprivate func gameOver(_ didWin: Bool) {
        let menuScene = MenuScene(size: size, didWin: didWin)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        view?.presentScene(menuScene, transition: transition)
    }
}
