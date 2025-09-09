//
//  GameScene.swift
//  Pachinko
//
//  Created by Fahim Uddin on 9/9/25.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    /// Use this method for static elemnts such as background
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        /// if something collides, this  tell the insatcne of this class
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
    }
    
    /// use this method for user input such as user interaction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let object = nodes(at: location)
        
        if object.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box =  SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
                
            } else {
                let images = ["ballRed", "ballBlue", "ballCyan", "ballGrey", "ballRed", "ballYellow"]
                let ball = SKSpriteNode(imageNamed: images.randomElement()!)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                /// restitution refers to bounciness
                ball.physicsBody?.restitution = 0.4
                ball.position = location
                ball.name = "ball"
                
                /// notifies GameScene abotu EVERY collsion ball is in
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                addChild(ball)
            }
            
        }
        
    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func makeBouncer(at postion: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = postion
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        /// isDynamic refers to whether collisons with other nodes cause movemnt or if it stays still lke an anchor
        bouncer.physicsBody?.isDynamic = false
        
        addChild(bouncer)
    }
    
    func makeSlot(at postion: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = postion
        slotGlow.position = postion
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotGlow)
        addChild(slotBase)
        
        /// shorter duration means the action happnes faster since it has a shorter amount of time and vice versa so here duration is controlling speed
        /// use SKAction to add animation.action to sprite
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        /// then use run method to execute on the action
        slotGlow.run(spinForever)
    }
    
    func collsion(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        }  else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
        
    }
    
    /// this is called automatically two physics bodies configured for collion touch each other
    /// part of SKPhysicsContactDelegate
    /// contact object is a report for the two things which collided
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collsion(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collsion(between: nodeB, object: nodeA)
        }
    }
}
