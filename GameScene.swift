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
import GoogleMobileAds

class GameScene: SKScene, SKPhysicsContactDelegate {
    
//    public static var adWatched = false
    
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
    var ptsOffset = 0
    var arrayOfPlayers = [AVAudioPlayer]()
    
    private var world: SKNode!
    private var fade: SKSpriteNode!
    private var movement, offset, minY: CGFloat!
    private var sliderTouch: UITouch?
    private var triggeredBtn: Button!
    private var (started, stopped, ended) = (false, false, false)
    private var bounds: Bounds!
    var doorOpens = false
    
    func continueGameplay() {
//        if GameScene.adWatched {
            let action = SKAction.run {
                self.manager.finishMenu(visible: false)
                self.player.getAlive()
                self.ended = false
//                self.player.push(power: 200)
                self.player.push(power: 170)
                self.platformFactory.highestY = self.player.sprite.position.y + 100
                let move = SKAction.moveTo(x: 0, duration: 1)
                self.cam.node.run(move)
                self.minY = self.player.sprite.position.y - 100
                
                let scale = SKAction.scale(to: 0.95, duration: 1)
                scale.timingMode = SKActionTimingMode.easeOut
                
                let rotate = SKAction.rotate(toAngle: 0, duration: 1)
                rotate.timingMode = SKActionTimingMode.easeOut
                
                let go = SKAction.run {
                    self.physicsWorld.speed = 1
                    self.world.isPaused = false
                }
                
                let scaleStop = SKAction.group([scale, go])
                self.cam.node.run(SKAction.group([scaleStop, rotate]))
                self.manager.show(self.manager.line, self.manager.hpBorder, self.manager.pauseBtn, self.manager.gameScore)
            }
            run(action)
//            GameScene.adWatched = false
//        }
    }
    
    override func didMove(to view: SKView) {
        loadData()
        
        fade = SKSpriteNode(color: .black, size: frame.size)
        fade.alpha = GameScene.restarted ? 1 : 0
        fade.zPosition = 25
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -23.5)
        
        cam = Camera(self)
        cam.node.addChild(fade)
        cam.node.position.y = -60
        
        world = SKNode()
        manager = Manager(self, world)
        manager.show(manager.line)
        
        player = Player(world.childNode(withName: "Character")!)
        player.turn(left: true)
        
        sliderTip = Tip("HOLD AND MOVE", CGPoint(x: 35, y: 70))
        manager.slider.addChild(sliderTip.sprite)
        
        doorTip = Tip("SKIN SHOP", CGPoint(x: -50, y: 100))
        doorTip.flip(0.75)
        manager.door.addChild(doorTip.sprite)
        
        addChild(world)
        trail = Trail(player.sprite, Skins[GameScene.skinIndex].trailColors)
        trail.create(in: world)
        
        platformFactory = PlatformFactory(world, frame.height/2, 125...200)
        cloudFactory = CloudFactory(frame, world)
        bounds = Bounds()
        minY = player.sprite.position.y
        
        manager.slider.position.x = player.sprite.position.x
        movement = player.sprite.position.x
        cam.node.setScale(0.75)
        
        if GameScene.restarted {
            let a = SKAction.fadeOut(withDuration: 0.25)
            a.timingMode = .easeOut
            fade.run(a)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.adWatchedUI), name: NSNotification.Name(rawValue: "adWatchedUI"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.adDismissed), name: NSNotification.Name(rawValue: "adDismissed"), object: nil)
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
                manager.createEmitter(world, "DustParticles", contact.contactPoint)
                
                // Define platform obj
                let node = extractNode("platform", contact)!
                let platform = platformFactory.findPlatform(node)
                
                DispatchQueue.global(qos: .background).async {
                    let audioName = "\(platform.type)-footstep"
                    GSAudio.sharedInstance.playSound(soundFileName: audioName)
                    GSAudio.sharedInstance.playSound(soundFileName: "wind")
                }
                
                // Pick items up
                if platform.hasItems() {
                    cam.shake(30, 1, 0, 0.1)
                    for item in platform.items {
                        if item.wasTouched {
                            switch item {
                            case is Coin:
                                pickItem(item, platform)
                                manager.collectCoin((item as! Coin).currency)
                            case is Food:
                                var energy: CGFloat = CGFloat((item as! Food).energy)
                                energy *= Skins[GameScene.skinIndex].name == "farmer" ? 1.25 : 1
                                player.editHp(Int(energy))
                                pickItem(item, platform)
                            default:
                                return
                            }
                        }
                    }
                } else {
                    cam.shake(20, 1, 0, 0.1)
                }
                
                // Harm and push
                player.editHp(-platform.damage)
                if player.isAlive {
                    let power: CGFloat = Skins[GameScene.skinIndex].name == "ninja" ? CGFloat(platform.power) * 1.125 : CGFloat(platform.power)
                    player.push(power: Int(power))
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
        cam.shake(1.25, 5, 0, 1.5)
        
        if !stopped {
            movement = lerp(player.sprite.position.x, manager.slider.position.x, 0.27)
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
            let score = Int(player.sprite.position.y/100) + ptsOffset
            if score > 0 && score > Int(player.score) {
                manager.setScore(score, platformFactory.stage)
                player.setScore(score)
                if score%100 == 0 {
                    platformFactory.stage.upgrade(score/100)
                    platformFactory.stage.setBarLabels(btm: manager.bottomStage, top: manager.topStage)
                }
            }
        }
        
        if started {
            cam.node.position.y = lerp(cam.node.position.y, player.sprite.position.y, cam.easing)
            
            if player.isFalling() {
                if player.currentAnim != player.fallAnim {
                    player.runAnimation(player.fallAnim)
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
            if node == manager.slider && !doorOpens {
                DispatchQueue.global(qos: .background).async {
                    GSAudio.sharedInstance.playSounds(soundFileNames: "button", "wood-footstep", "wind")
//                    GSAudio.sharedInstance.playSound(soundFileName: "button")
                }
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
                ptsOffset = Skins[GameScene.skinIndex].name == "bman" ? 100 : 0
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAd"), object: nil)
                
                let push = SKAction.run {
                    self.player.push(power: 170)
                    self.cam.shake(50, 6, 6, 0.055)
                    let scale = SKAction.scale(to: 0.95, duration: 1.25)
                    scale.timingMode = SKActionTimingMode.easeInEaseOut
                    self.cam.node.run(scale)
                }
                player.sprite.removeAllActions()
                cloudFactory.faster()
                manager.show(manager.line, manager.hpBorder, manager.pauseBtn, manager.gameScore, manager.stageBorder)
                run(push)
                manager.hide(sliderTip.sprite, manager.w, manager.b, manager.g)
                doorTip.sprite.alpha = 0
                
            } else if node == manager.door {
                doorOpens = true
                DispatchQueue.global(qos: .background).async {
                    GSAudio.sharedInstance.playSound(soundFileName: "door-open")
                }
                
                manager.door.run(manager.doorAnim)
                manager.hide(manager.line, manager.w, manager.b, manager.g)
                
                let scale = SKAction.scale(to: 0.025, duration: 0.6)
                scale.timingMode = SKActionTimingMode.easeInEaseOut
                
                let doorPos = CGPoint(x: manager.house.position.x + manager.door.frame.maxX, y: manager.house.position.y + manager.door.frame.minY)
                let move = SKAction.move(to: doorPos, duration: 0.6)
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
                DispatchQueue.global(qos: .background).async {
                    GSAudio.sharedInstance.playSound(soundFileName: "button")
                }
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
                gameState(paused: false)
            } else if node == manager.pauseBtn {
                sliderTouch = nil
                //playSound(type: .UI, audioName: "push-down")
                stopped ? gameState(paused: false) : gameState(paused: true)
                manager.line.isHidden = false
                manager.slider.isHidden = false
            }
        }
        else if ended {
            if node == manager.slider {
                DispatchQueue.global(qos: .background).async {
                    GSAudio.sharedInstance.playSound(soundFileName: "button")
                }
                sliderTouch = touch
                offset = manager.slider.position.x - sliderTouch!.location(in: cam.node).x
                manager.slider.texture = SKTexture(imageNamed: "slider-1").px()
//                GameScene.adWatched = true
                continueGameplay()
            } else if node == manager.menuBtn.sprite || node == manager.menuBtn.label {
                DispatchQueue.global(qos: .background).async {
                    GSAudio.sharedInstance.playSound(soundFileName: "button")
                }
                manager.menuBtn.push()
                //playSound(type: .UI, audioName: "push-down")
                triggeredBtn = manager.menuBtn
                restart()
            } else if node == manager.advertBtn.sprite || node == manager.advertBtn.label {
                DispatchQueue.global(qos: .background).async {
                    GSAudio.sharedInstance.playSound(soundFileName: "button")
                }
                manager.advertBtn.push()
                triggeredBtn = manager.advertBtn
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAd"), object: nil)
//                continueGameplay()
            }
        }
    }
    
    @objc func adWatchedUI() {
        manager.advertBtn.sprite.isHidden = true
        manager.menuBtn.sprite.position = manager.advertBtn.sprite.position
        manager.show(manager.line)
        /* If watched an advertisement */
        //            advertBtn.sprite.isHidden = true
        //            menuBtn.sprite.position = advertBtn.sprite.position
        //            show(line)
                    //
    }
    
    @objc func adDismissed() {
        manager.advertBtn.setColor(.gray)
        manager.advertBtn.release()
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
        let wait = SKAction.wait(forDuration: 0.4)
        let physics = SKAction.run {
            self.player.sprite.physicsBody!.velocity = CGVector(dx: 0, dy: 50)
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -18)
            self.physicsWorld.speed = 1
            self.world.isPaused = false
            let a = SKAction.fadeIn(withDuration: 0.4)
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
        ended = true
        let wait = SKAction.wait(forDuration: wait)
        let action = SKAction.run {
            DispatchQueue.global(qos: .background).async {
                GSAudio.sharedInstance.playSound(soundFileName: "hurt")
            }
            self.sliderTouch = nil
            self.manager.finishMenu(visible: true)
            self.platformFactory.clean()
            //self.playSound(type: .world, audioName: "hurt")
            
            let scale = SKAction.scale(to: 0.25, duration: 1)
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
        manager.createEmitter(world, String(name), pos)
        if item is Coin {
            manager.createLabel(world, platform.sprite.position)
            DispatchQueue.global(qos: .background).async {
                GSAudio.sharedInstance.playSound(soundFileName: "coin-pickup")
            }
        } else if item is Food {
            DispatchQueue.global(qos: .background).async {
                GSAudio.sharedInstance.playSound(soundFileName: "food-pickup")
            }
        }
        
        platformFactory.removeItem(item, from: platform)
//        cam.earthquake()
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
