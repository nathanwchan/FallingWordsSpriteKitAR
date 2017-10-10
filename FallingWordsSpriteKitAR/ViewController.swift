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
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var gameCompleteView: UIView!
    @IBOutlet weak var gameCompleteStackView: UIStackView!
    
    private var speechRecognizer: SFSpeechRecognizer?
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var wordProvider: WordProvider?
    var wordProviderType: String?
    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "Score: \(score)"
        }
    }
    var lastWord: String?
    var currentCompletedWordIndex = 0
    
    func setupGameCompleteView() {
        gameCompleteView.backgroundColor = UIColor(red: 0.06, green: 0.29, blue: 0.56, alpha: 1.0)
        gameCompleteStackView.translatesAutoresizingMaskIntoConstraints = false
        gameCompleteStackView.distribution = .equalSpacing
        gameCompleteStackView.alignment = .fill
        gameCompleteStackView.spacing = 20
        
        let playAgainButton = UIButton(frame: .zero)
        playAgainButton.addTarget(self, action: #selector(self.startGameSession), for: .touchUpInside)
        playAgainButton.setTitle("Play Again", for: .normal)
        playAgainButton.setTitleColor(UIColor(red: 0.06, green: 0.29, blue: 0.56, alpha: 1.0), for: .normal)
        playAgainButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 23)
        playAgainButton.backgroundColor = .white
        playAgainButton.layer.cornerRadius = 20
        playAgainButton.heightAnchor.constraint(equalToConstant: 50)
        
        gameCompleteStackView.addArrangedSubview(playAgainButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGameCompleteView()
        
        var languageCode = "en-US"
        if let wordProviderType = wordProviderType, wordProviderType == "chinese" {
            languageCode = "zh-Hans"
        }
        wordProvider = WordProvider(type: wordProviderType ?? "simple")
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: languageCode))
        
        sceneView.delegate = self
        speechRecognizer?.delegate = self
        
        startGameSession()
        
        for _ in 0..<Globals.maxWords {
            let uiview = UIView.init(frame: .zero)
            uiview.backgroundColor = .gray
            progressStackView.addArrangedSubview(uiview)
            progressStackView.distribution = .fillEqually
            progressStackView.alignment = .fill
            progressStackView.spacing = 1
        }
        wordsLabel.text = "Grade \(wordProviderType?.last ?? "1")"
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
        }
        
        // Show statistics such as fps and node count
//        sceneView.showsFPS = true
//        sceneView.showsNodeCount = true
        
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
    
    @objc func startGameSession() {
        gameCompleteView.isHidden = true
        
        startRecording()
        
        score = 0
        currentCompletedWordIndex = 0
        for uiview in progressStackView.arrangedSubviews {
            uiview.backgroundColor = .gray
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        sceneView.scene?.view?.isPaused = false
    }
    
    func gameSessionComplete() {
        stopRecording()
        
        sceneView.session.pause()
        sceneView.scene?.view?.isPaused = true
        sceneView.scene?.removeAllChildren()
        
        gameCompleteView.isHidden = false
    }
    
    func missedWord(_ word: String) {
        print("missedWord: \(word)")
        let image = UIImage(named: "death")
        let imageView = UIImageView(image: image)
        imageView.alpha = 0.75
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        UIView.animate(withDuration: 2, animations: {
            imageView.alpha = 0.0
        }, completion: { _ in
            imageView.removeFromSuperview()
        })
        
        redLabel.alpha = 1.0
        redLabel.text = word
        
        UIView.animate(withDuration: 4, animations: {
            self.redLabel.alpha = 0.0
        }, completion: { _ in
        })
        
        if currentCompletedWordIndex >= Globals.maxWords - 1 {
            gameSessionComplete()
        } else {
            progressStackView.arrangedSubviews[currentCompletedWordIndex].backgroundColor = .red
            currentCompletedWordIndex += 1
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            
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
            
            if error != nil || isFinal {
                self.stopRecording()
            }
        })
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopRecording() {
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
    }
    
    // MARK: - ARSKViewDelegate
    
    func findMatchingWordInScene(word: String) {
        if let currentFrame = sceneView.session.currentFrame {
            for anchor in currentFrame.anchors {
                if let someNode = sceneView.node(for: anchor){
                    if let labelNode = someNode as? SKLabelNode,
                        let nodeText = labelNode.text {
                        if nodeText.lowercased() == word.lowercased() {
                            // SUCCESS: word match!
                            labelNode.action(forKey: "fall")?.speed = -1
                            labelNode.run( SKAction.sequence([
                                    SKAction.group([
                                        SKAction.wait(forDuration: 1),
                                        SKAction.fadeOut(withDuration: 1)
                                        ]),
                                    SKAction.run({
                                        labelNode.removeFromParent()
                                        if self.currentCompletedWordIndex >= Globals.maxWords - 1 {
                                            self.gameSessionComplete()
                                        } else {
                                            self.progressStackView.arrangedSubviews[self.currentCompletedWordIndex].backgroundColor = .green
                                            self.currentCompletedWordIndex += 1
                                        }
                                    }),
                                ]))
                            score += 1
                        }
                    }
                }

            }
        }
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        guard let wordProvider = wordProvider else {
            return nil
        }
        
        let newWord = wordProvider.getNextWord()
        print("newWord: \(newWord)")
        
        let shadowLabelNode = SKLabelNode(text: newWord)
        shadowLabelNode.fontSize = 50
        shadowLabelNode.fontName = "HelveticaNeue"
        shadowLabelNode.horizontalAlignmentMode = .center
        shadowLabelNode.verticalAlignmentMode = .center
        shadowLabelNode.position = CGPoint(x: 2, y: -2)
        shadowLabelNode.fontColor = UIColor.black
        shadowLabelNode.zPosition = -1
        
        let labelNode = SKLabelNode(text: newWord)
        labelNode.fontSize = 50
        labelNode.fontName = "HelveticaNeue"
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        labelNode.addChild(shadowLabelNode)
        
        let moveDown = SKAction.moveTo(y: CGFloat(-400), duration: 7)
        let destroy = SKAction.run() {
            self.missedWord(newWord)
            labelNode.removeFromParent()
        }
        
        let seq = SKAction.sequence([moveDown, destroy])

        labelNode.removeAllActions()
        labelNode.run(seq, withKey: "fall")
        
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
