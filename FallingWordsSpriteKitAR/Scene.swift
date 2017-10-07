//
//  Scene.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/6/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    var lastUpdateTime: TimeInterval?
    let frameRate = 1.0 // in seconds
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//        if let lastUpdateTime = lastUpdateTime {
//            if currentTime - lastUpdateTime >= frameRate {
//                print(currentTime)
//                self.lastUpdateTime = currentTime
//            }
//        } else {
//            lastUpdateTime = currentTime
//        }
//
//        guard let sceneView = self.view as? ARSKView else {
//            return
//        }
//        if let currentFrame = sceneView.session.currentFrame {
//            for anchor in currentFrame.anchors {
//                if let someNode = sceneView.node(for: anchor){
//                    if let labelNode = someNode as? SKLabelNode {
////                        print(labelNode.text ?? "none")
//                    }
//                }
//
//            }
//        }
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation
            var translation = matrix_identity_float4x4
            translation.columns.3.x = -0.5
            translation.columns.3.z = -1
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
