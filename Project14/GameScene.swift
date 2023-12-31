//
//  GameScene.swift
//  Project14
//
//  Created by Yulian Gyuroff on 26.10.23.
//

import SpriteKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var gameOver: SKSpriteNode!
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
            gameOverLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Score: 0"
        gameOverLabel.position = CGPoint(x: 390, y: 320)
        gameOverLabel.horizontalAlignmentMode = .left
        gameOverLabel.fontSize = 48
        gameOverLabel.zPosition = 2
        //addChild(gameOverLabel)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + i*170, y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + i*170, y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + i*170, y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + i*170, y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                // you shouldn't wack this penguin
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name  == "charEnemy"{
                // Enemy penguin is hit
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
        if numRounds >= 30 {
            print("gameOver tapped")
            gameOver.removeFromParent()
            gameOverLabel.removeFromParent()
            score = 0
            popupTime = 0.85
            numRounds = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.createEnemy()
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            gameOver.name = "gameOver"
            addChild(gameOver)
            run(SKAction.playSoundFileNamed("gameover", waitForCompletion: true))
            addChild(gameOverLabel!)
            return
        }
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...14) > 4 { slots[1].show(hideTime: popupTime)}
        if Int.random(in: 0...14) > 8 { slots[2].show(hideTime: popupTime)}
        if Int.random(in: 0...14) > 10 { slots[3].show(hideTime: popupTime)}
        if Int.random(in: 0...14) > 11 { slots[4].show(hideTime: popupTime)}
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
        
    }
    
}
