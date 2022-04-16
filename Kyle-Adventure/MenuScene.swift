//
//  MenuScene.swift
//  Kyle-Adventure
//
//  Created by anh thu on 2022-03-27.
//

import SpriteKit

class MenuScene: SKScene {
    var didWin: Bool

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    init(size: CGSize, didWin: Bool) {
        self.didWin = didWin
        super.init(size: size)
        scaleMode = .aspectFill
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0, alpha: 1)

        // Set up labels
        let text = didWin ? "CLEAR!" : "GAME OVER..."
        let winLabel = SKLabelNode(text: text)
        winLabel.fontName = "AvenirNext-Bold"
        winLabel.fontSize = 40
        winLabel.fontColor = .white
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY*1.5)
        addChild(winLabel)

        let label = SKLabelNode(text: "Play again!")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 25
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)

        // Play sound
        let soundToPlay = didWin ? "game_clear.mp3" : "game_over.mp3"
        run(SKAction.playSoundFileNamed(soundToPlay, waitForCompletion: false))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = GameScene(fileNamed: "GameScene")
        else {
            fatalError("GameScene not found")
        }
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
}
