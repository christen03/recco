//
//  EmojiPhysicsScene.swift
//  Recco
//
//  Created by chris10 on 5/11/25.
//

import SwiftUI
import SpriteKit

class EmojiPhysicsScene: SKScene {
    private var groundNode: SKNode?
    private var leftWallNode: SKNode?
    private var rightWallNode: SKNode?

    private var lastSpawnTime: TimeInterval = 0
    private let spawnInterval: TimeInterval = 0.1 // Interval between emoji spawns
    var maxEmojisToSpawn: Int
    private var emojisSpawned: Int = 0
    private var uniqueEmojiSpawnIndex: Int = 0

    let emojiCharacters = ["🌈", "🦢", "💿", "👽", "🍎", "🧊", "🎾", "🍭", "🧩", "🥩", "🎨", "🍇", "🍆", "🥐", "🛸", "🌷", "🏝️", "🧸", "🎈", "🧀", "✂️", "⛱️", "🪑", "🌀", "🧢", "🧤", "🌕", "🦠", "🔮", "🪩", "🖼️", "🌐"]
    

    init(size: CGSize, maxEmojis: Int) {
        self.maxEmojisToSpawn = maxEmojis
        super.init(size: size)
        self.scaleMode = .resizeFill
        self.backgroundColor = .clear // Transparent background
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -3.0) // Adjusted gravity
        setupBoundaries()
    }

    func setupBoundaries() {
        // Clear existing boundaries before recreating
        groundNode?.removeFromParent()
        leftWallNode?.removeFromParent()
        rightWallNode?.removeFromParent()

        // Ground
        let ground = SKNode()
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 1), to: CGPoint(x: size.width, y: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.friction = 0.8
        ground.physicsBody?.restitution = 0.05 // Less bouncy
        addChild(ground)
        self.groundNode = ground

        // Left Wall
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 1, y: 0), to: CGPoint(x: 1, y: size.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.friction = 0.5
        addChild(leftWall)
        self.leftWallNode = leftWall

        // Right Wall
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: size.width - 1, y: 0), to: CGPoint(x: size.width - 1, y: size.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.friction = 0.5
        addChild(rightWall)
        self.rightWallNode = rightWall
    }

    public func updateSceneSize(_ newSize: CGSize) {
        self.size = newSize
        setupBoundaries()
    }

    func spawnEmoji() {
           guard emojisSpawned < maxEmojisToSpawn else { return }
           guard !emojiCharacters.isEmpty else { // Safety check for empty array
               emojisSpawned += 1 // Still increment to avoid infinite loop if misconfigured
               return
           }

           let emojiChar: String
           if uniqueEmojiSpawnIndex < emojiCharacters.count {
               emojiChar = emojiCharacters[uniqueEmojiSpawnIndex]
               uniqueEmojiSpawnIndex += 1
           } else {
               emojiChar = emojiCharacters.randomElement()!
           }
           
           let emojiNode = SKLabelNode(text: emojiChar)
           let fontSize = CGFloat.random(in: 40...55)
           emojiNode.fontSize = fontSize
           emojiNode.verticalAlignmentMode = .center
           emojiNode.horizontalAlignmentMode = .center
           
           let halfWidth = emojiNode.frame.width / 2
           let halfHeight = emojiNode.frame.height / 2
           let minX = halfWidth + 5
           let maxX = size.width - halfWidth - 5
           
           guard maxX > minX else {
               emojisSpawned += 1
               return
           }
           
           let xPosition = CGFloat.random(in: minX...maxX)
           emojiNode.position = CGPoint(x: xPosition, y: size.height + halfHeight)

           let radius = max(5, emojiNode.frame.width * 0.40)
           emojiNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
           
           if let pb = emojiNode.physicsBody {
               pb.mass = 0.1 + CGFloat.random(in: -0.01...0.01)
               pb.friction = 0.7
               pb.restitution = 0.1
               pb.allowsRotation = true
               pb.linearDamping = 0.3
               pb.angularDamping = 0.3
           }

           addChild(emojiNode)
           emojisSpawned += 1
       }


    override func update(_ currentTime: TimeInterval) {
        if lastSpawnTime == 0 {
            lastSpawnTime = currentTime
        }

        if currentTime - lastSpawnTime > spawnInterval {
            if emojisSpawned < maxEmojisToSpawn {
                spawnEmoji()
                lastSpawnTime = currentTime
            }
        }
    }
}
