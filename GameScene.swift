//
//  GameScene.swift
//  Jump
//
//  Created by Vladislav Deba on 7/30/19.
//  Copyright © 2019 Vladislav Deba. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var cam: Camera!
    private var manager: Manager!
    private var player: Player!
    private var trail: Trail!
    private var cloudFactory: CloudFactory!
    private var platformFactory: PlatformFactory!
    private var sliderTip, doorTip: Tip!
    static var restarted = false
    
    static var skinIndex: Int!
    static var ownedSkins: [Int]!
    
    private var world: SKNode!
    private var fade: SKSpriteNode!
    private var movement, offset, minY: CGFloat!
    private var sliderTouch: UITouch?
    private var triggeredBtn: Button!
    private var (started, stopped, ended) = (false, false, false)
    private var bounds: Bounds!
    
//    var platformAudio = AVAudioPlayer(), coinAudio = AVAudioPlayer(), foodAudio = AVAudioPlayer()
    
//    enum AudioPlayerType {
//        case UI
//        case world
//        case platform
//        case coin
//        case food
//    }
    
//    func playSound(type: AudioPlayerType, audioName: String = "") {
//        DispatchQueue.global(qos: .background).async {
//            var player: AVAudioPlayer!
//            do {
//                switch type {
//                case .platform, .UI, .world:
//                    self.platformAudio = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: audioName, withExtension: "wav")!)
////                    self.platformAudio.prepareToPlay()
//                    player = self.platformAudio
//                case .coin:
//                    player = self.coinAudio
//                case .food:
//                    self.foodAudio = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "food" + String(Int.random(in: 1...2)), withExtension: "wav")!)
//                    player = self.foodAudio
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//
//            if type == .UI {
//                player.volume = 0.6
//            }
//
//            player.prepareToPlay()
//            player.play()
//        }
//    }
    
    override func didMove(to view: SKView) {
        loadData()
//        saveData()
//        do {
//            coinAudio = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "coin-pickup", withExtension: "wav")!)
//            foodAudio = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "food1", withExtension: "wav")!)
//            coinAudio.prepareToPlay()
//            foodAudio.prepareToPlay()
//
//            let session = AVAudioSession()
//            do {
//                try session.setCategory(.playback)
//            } catch {
//                print(error.localizedDescription)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.alpha = GameScene.restarted ? 1 : 0
        fade.zPosition = 25
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23)
        
        cam = Camera(self)
        cam.node.addChild(fade)
        cam.node.position.y = -60
        
        world = SKNode()
        manager = Manager(self, world)
        manager.show(manager.line)
        
        player = Player(world.childNode(withName: "Character")!)
        player.turn(left: true)
        
        sliderTip = Tip("START GAME", CGPoint(x: 35, y: 70))
        manager.slider.addChild(sliderTip.sprite)
        
        doorTip = Tip("CHANGE SKIN", CGPoint(x: -50, y: 100))
        doorTip.flip(0.75)
        manager.door.addChild(doorTip.sprite)
        
        addChild(world)
//        trail = Trail(target: player.sprite)
        trail = Trail(player.sprite)
        trail.create(in: world)
//        trail.create(in: world)
        
        platformFactory = PlatformFactory(world, frame.height/2, 125...200)
        cloudFactory = CloudFactory(frame, world)
        bounds = Bounds()
        minY = player.sprite.position.y
        
        manager.slider.position.x = player.sprite.position.x
        movement = player.sprite.position.x
        cam.node.setScale(0.75)
        
        if GameScene.restarted {
            let a = SKAction.fadeOut(withDuration: 0.4)
            a.timingMode = .easeOut
            fade.run(a)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if player.isAlive {
            let col: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            if col == Collision.playerFood || col == Collision.playerCoin {
                if let node = extractNode("item", contact) {
                    let item = platformFactory.findItem(node)
                    item.wasTouched = true
                }
            }
            
            if player.isFalling() && col == Collision.playerPlatform {
                // Play animation and create trail line
                player.runAnimation(player.landAnim)
                trail.create(in: world, 30.0)
                manager.addEmitter(world, "DustParticles", contact.contactPoint)
                
                // Define platform obj
                let node = extractNode("platform", contact)!
                let platform = platformFactory.findPlatform(node)
                
                
                //let audioName = "\(platform.type)-footstep"
                //playSound(type: .platform, audioName: audioName)
                
                // Pick items up
                if platform.hasItems() {
                    for item in platform.items {
                        if item.wasTouched {
                            switch item {
                            case is Coin:
                                pickItem(item, platform)
                                manager.addCoin((item as! Coin).currency)
                            case is Food:
                                player.editHp((item as! Food).energy)
                                pickItem(item, platform)
                            default:
                                return
                            }
                        }
                    }
                }
                
                // Harm and push
                player.editHp(-platform.damage)
                if player.isAlive {
                    player.push(power: platform.power)
                } else {
                    player.push(power: 70)
                    finish(0.7)
                }
                
                if platform.type == .sand {
                    platform.fall(contact.contactPoint.x)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.shake(1, 5, 0, 1.5)
        
        if !stopped {
            movement = lerp(player.sprite.position.x, manager.slider.position.x, 0.25)
            player.sprite.position.x = movement
            
            // Define death point
            if let lowestY = platformFactory.lowestY(), player.sprite.position.y > lowestY {
                minY = lowestY
            }
            
            // Create trail line
            if trail.distance() > 60 && !ended {
                trail.create(in: world)
            }
            
            // Set score
            let score = Int(player.sprite.position.y/100)
            if score > 0 && score > Int(player.score) {
                manager.setScore(score)
                player.setScore(score)
                if score%100 == 0 {
                    platformFactory.stage.upgrade(score/100)
                }
            }
        }
        
        if started {
            cam.node.position.y = lerp(cam.node.position.y, player.sprite.position.y, cam.easing)
            
            if player.isFalling() {
                if player.currentAnim != player.fallAnim {
                    player.runAnimation(player.fallAnim)
                }
                if player.sprite.physicsBody!.velocity.dy < -2100 {
                    player.sprite.physicsBody!.velocity.dy = -2100
                }
            }
            
            if !ended {
                _ = getBounds()
                if platformFactory.canBuild(player.sprite.position.y) {
                    platformFactory.create()
                }
                platformFactory.remove(bounds.minY)
                
                if player.sprite.position.y < minY {
                    finish(0)
                }
            }
        } else if !started && !ended {
            started = player.sprite.position.y > 0
        }
        
        if ended {
            cam.node.position.x = lerp(cam.node.position.x, player.sprite.position.x, cam.easing/3)
        }
        
        if !world.isPaused {
            cloudFactory.create(player.sprite.position.y, started)
            cloudFactory.bounds = getBounds()
            cloudFactory.remove()
            cloudFactory.move()
        }
        
        manager.removeLabels(cam.node.frame.minY - frame.height/2)
        manager.removeEmitters(cam.node.frame.minY - frame.height/2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let node = atPoint(touch.location(in: self))
        
        if !started {
            if node == manager.slider {
                sliderTouch = touch
                //playSound(type: .UI, audioName: "push-down")
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
                
                let push = SKAction.run {
                    self.player.push(power: 170)
                    self.cam.shake(50, 6, 6, 0.055)
                    let scale = SKAction.scale(to: 0.95, duration: 1)
                    scale.timingMode = SKActionTimingMode.easeIn
                    self.cam.node.run(scale)
                }
                player.sprite.removeAllActions()
                cloudFactory.speedUp()
                manager.show(manager.line, manager.hpBorder, manager.pauseBtn, manager.gameScore)
                run(push)
                manager.hide(sliderTip.sprite, manager.w, manager.b, manager.g)
                doorTip.sprite.alpha = 0
                
            } else if node == manager.door {
                //playSound(type: .world, audioName: "door-open")
                
                manager.door.run(manager.doorAnim)
                manager.hide(manager.line, manager.w, manager.b, manager.g)
                
                let scale = SKAction.scale(to: 0.025, duration: 0.8)
                scale.timingMode = SKActionTimingMode.easeInEaseOut
                
                let doorPos = CGPoint(x: manager.house.position.x + manager.door.frame.maxX, y: manager.house.position.y + manager.door.frame.minY)
                let move = SKAction.move(to: doorPos, duration: 0.8)
                move.timingMode = SKActionTimingMode.easeIn
                
                let wait = SKAction.wait(forDuration: 0.4)
                let fade = SKAction.run {
                    let a = SKAction.fadeIn(withDuration: 0.4)
                    a.timingMode = .easeIn
                    self.fade.run(a)
                }
                let act = SKAction.run {
                    let scene = ShopScene(size: self.frame.size)
                    self.view!.presentScene(scene)
                    self.removeAllChildren()
                }
                run(SKAction.sequence([SKAction.group([wait, fade]), act]))
                cam.node.run(SKAction.group([scale, move]))
            }
        }
        else if started && !ended {
            if node == manager.slider {
                sliderTouch = touch
                //playSound(type: .UI, audioName: "push-down")
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
            } else if node == manager.pauseBtn {
                sliderTouch = nil
                //playSound(type: .UI, audioName: "push-down")
                stopped ? gameState(paused: false) : gameState(paused: true)
            }
        }
        else if ended {
            if node == manager.menuBtn.sprite || node == manager.menuBtn.label {
                manager.menuBtn.push()
                //playSound(type: .UI, audioName: "push-down")
                triggeredBtn = manager.menuBtn
                restart()
            } else if node == manager.advBtn.sprite || node == manager.advBtn.label {
                manager.advBtn.push()
                triggeredBtn = manager.advBtn
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let st = sliderTouch {
            let touchX = st.location(in: cam.node).x
            let halfLine = manager.line.size.width / 2
            
            if touchX > -halfLine && touchX < halfLine {
                manager.slider.position.x = touchX + offset
                if player.sprite.position.x < manager.slider.position.x {
                    player.turn(left: false)
                } else {
                    player.turn(left: true)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let st = sliderTouch, touches.contains(st) {
            sliderTouch = nil
            manager.slider.texture = SKTexture(imageNamed: "slider-0").px()
        }
        else if triggeredBtn != nil {
            triggeredBtn.release()
            triggeredBtn = nil
        }
    }
    
    
    func loadData() {
        let defaults = UserDefaults.standard
        GameScene.ownedSkins = defaults.value(forKey: "ownedSkins") as? [Int] ?? [0]
        GameScene.skinIndex = defaults.value(forKey: "skinIndex") as? Int ?? 0
    }
    
    static func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(GameScene.ownedSkins, forKey: "ownedSkins")
        defaults.set(GameScene.skinIndex, forKey: "skinIndex")
    }
    
    private func restart() {
        let wait = SKAction.wait(forDuration: 0.5)
        let physics = SKAction.run {
            self.player.sprite.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
            self.physicsWorld.speed = 1
            self.world.isPaused = false
            let a = SKAction.fadeIn(withDuration: 0.5)
            a.timingMode = .easeIn
            self.fade.run(a)
        }
        let act = SKAction.run {
            GameScene.restarted = true
            
            let defaults = UserDefaults.standard
            var wq : Int = defaults.value(forKey: "wooden") as? Int ?? 0
            wq += Int(self.manager.wLabel.text!)!
            defaults.set(wq, forKey: "wooden")
            var bq : Int = defaults.value(forKey: "bronze") as? Int ?? 0
            bq += Int(self.manager.bLabel.text!)!
            defaults.set(bq, forKey: "bronze")
            var gq : Int = defaults.value(forKey: "golden") as? Int ?? 0
            gq += Int(self.manager.gLabel.text!)!
            defaults.set(gq, forKey: "golden")
            
            let scene = GameScene(size: self.frame.size)
            scene.scaleMode = SKSceneScaleMode.aspectFill
            self.view!.presentScene(scene)
            self.removeAllChildren()
        }
        run(SKAction.sequence([SKAction.group([wait, physics]), act ]))
    }
    
    func getBounds() -> Bounds {
        bounds.minX = -frame.size.width/2 + cam.node.position.x
        bounds.minY = cam.node.frame.minY - frame.height/2
        bounds.maxX = frame.size.width/2 + cam.node.position.x
        bounds.maxY = cam.node.frame.maxY + frame.height/2
        return bounds
    }
    
    private func finish(_ wait: TimeInterval) {
        let wait = SKAction.wait(forDuration: wait)
        let action = SKAction.run {
            self.sliderTouch = nil
            self.manager.switchUI()
            //self.playSound(type: .world, audioName: "hurt")
            
            let scale = SKAction.scale(to: 0.3, duration: 1)
            scale.timingMode = SKActionTimingMode.easeIn
            scale.speed = 3
            
            let angle: CGFloat = self.player.sprite.position.x > 0 ? -0.3 : 0.3
            let rotate = SKAction.rotate(toAngle: angle, duration: 1)
            rotate.timingMode = SKActionTimingMode.easeInEaseOut
            rotate.speed = 0.6
            
            let stop = SKAction.run {
                self.physicsWorld.speed = 0
                self.world.isPaused = true
            }
            
            let scaleStop = SKAction.sequence([scale, stop])
            self.cam.node.run(SKAction.group([scaleStop, rotate]))
            self.manager.hide(self.manager.line, self.manager.hpBorder, self.manager.pauseBtn, self.manager.gameScore)
            self.ended = true
        }
        
        run(SKAction.sequence([wait, action]))
    }
    
    private func pickItem(_ item: Item, _ platform: Platform) {
        // breaditem; goldenitem
        var name = item.sprite.name!.dropLast(4)
        // bread; golden
        name = name.first!.uppercased() + name.dropFirst()
        // Bread; Golden
        name += "Particles"
        // BreadParticles; GoldenParticles
        
        let pos = CGPoint(x: platform.sprite.position.x + item.sprite.position.x, y: platform.sprite.position.y + item.sprite.position.y)
        manager.addEmitter(world, String(name), pos)
        if item is Coin {
            manager.addLabel(world, platform.sprite.position)
            //playSound(type: .coin)
        } else if item is Food {
            //playSound(type: .food)
        }
        
        platformFactory.removeItem(item, from: platform)
        cam.earthquake()
    }
    
    private func lerp(_ start: CGFloat, _ end: CGFloat, _ percent: CGFloat) -> CGFloat {
        return start + percent * (end - start)
    }
    
    private func extractNode(_ node: String, _ contact: SKPhysicsContact) -> SKNode? {
        return contact.bodyA.node!.name!.contains(node) ? contact.bodyA.node : contact.bodyB.node
    }
    
    private func gameState(paused: Bool) {
        if paused {
            manager.pauseBtn.texture = manager.playTexture
            physicsWorld.speed = 0
            manager.darken.alpha = 0.3
        } else {
            manager.pauseBtn.texture = manager.pauseTexture
            physicsWorld.speed = 1
            manager.darken.alpha = 0
        }
        
        stopped = paused
        world.isPaused = paused
        manager.line.isHidden = paused
        manager.slider.isHidden = paused
    }
}
