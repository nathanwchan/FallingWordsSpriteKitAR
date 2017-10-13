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
    let frameRate = 3.0 // in seconds
    var wordCounter = 0
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if wordCounter >= Globals.maxWords {
            return
        }
        if let lastUpdateTime = lastUpdateTime {
            if currentTime - lastUpdateTime >= frameRate {
                addNewWordToScene()
                wordCounter += 1
                self.lastUpdateTime = currentTime
            }
        } else {
            lastUpdateTime = currentTime
        }
    }

    func addNewWordToScene() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation
            var translation = matrix_identity_float4x4
            
            // Translate in up direction
            translation.columns.3.x = -0.5
            
            // Translate in left/right direction
            let horizontalTranslate = getRandomFloat(between: -1.0, and: 1.0)
            translation.columns.3.y = horizontalTranslate
            
            // Translate in forward (depth) direction
            let distanceFromCamera: Float = 1.0
            translation.columns.3.z = -getRightTriangleSideLength(horizontalTranslate, distanceFromCamera)
            
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            
            // show indicator if word spawns far enough away from camera view
            if abs(horizontalTranslate) > 0.3 {
                var image = UIImage(named: "chevron_left")
                if horizontalTranslate > 0 {
                    image = UIImage(named: "chevron_right")
                }
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                guard let view = self.view else {
                    return
                }
                view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(imageView)
                if horizontalTranslate < 0 {
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                    imageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
                } else {
                    imageView.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                }
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

                UIView.animate(withDuration: 2, animations: {
                    imageView.alpha = 0.0
                }, completion: { _ in
                    imageView.removeFromSuperview()
                })
            }
        }
    }
}
