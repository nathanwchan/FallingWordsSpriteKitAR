//
//  ViewController.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/6/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Speech

class ViewController: UIViewController, ARSKViewDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var sceneView: ARSKView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var wordsLabel: UILabel!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = String(describing: score)
        }
    }
    var lastWord: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
        }
        startRecording()
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func gameOver() {
//        sceneView.session.pause()
        print("game over")
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                guard let currentWord = result?.bestTranscription.segments.last?.substring.lowercased() else {
                    return
                }
                if self.lastWord == currentWord {
                    return
                }
                self.lastWord = currentWord
                print("speechrecognizer word: \(currentWord)")
                self.wordsLabel.text = currentWord
                self.findMatchingWordInScene(word: currentWord)
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    // MARK: - ARSKViewDelegate
    
    func findMatchingWordInScene(word: String) {
        if let currentFrame = sceneView.session.currentFrame {
            for anchor in currentFrame.anchors {
                if let someNode = sceneView.node(for: anchor){
                    if let labelNode = someNode as? SKLabelNode,
                        let nodeText = labelNode.text {
                        if nodeText.lowercased() == word.lowercased() {
                            labelNode.removeFromParent()
                            score += 1
                        }
                    }
                }

            }
        }
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let newWord = WordProvider.shared.getNextWord()
        print("newWord: \(newWord)")
        let labelNode = SKLabelNode(text: newWord) //"👾")
        labelNode.fontSize = 50
        labelNode.fontName = "HelveticaNeue"
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        let moveDown = SKAction.moveTo(y: CGFloat(-400), duration: 5)

        labelNode.removeAllActions()
        labelNode.run(moveDown) {
//            self.gameOver()
            labelNode.removeFromParent()
        }
        
        return labelNode
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
