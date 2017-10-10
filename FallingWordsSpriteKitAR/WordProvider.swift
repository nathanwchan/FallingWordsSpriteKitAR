//
//  WordProvider.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/7/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import Foundation

enum Dictionary {
    static let transportation = ["car", "bus", "plane", "limousine", "truck", "minivan", "convertible", "motorcycle", "bicycle"]
    static let simple = ["apple", "dog", "banana", "cat", "zebra", "chair"]
    static let chinese = ["今天", "分钟", "你好", "可以", "高兴", "吃", "谢谢"]
    
}

class WordProvider {
    var words: [String]
    var currentIndex = 0
    
    init(type: String = "simple") {
        switch type {
        case "transportation":
            words = Dictionary.transportation
        case "chinese":
            words = Dictionary.chinese
        default:
            if let filepath = Bundle.main.path(forResource: type, ofType: "txt") {
                do {
                    words = try String(contentsOfFile: filepath).components(separatedBy: "\n")
                } catch {
                    words = Dictionary.simple
                }
            } else {
                words = Dictionary.simple
            }
        }
        
        words.shuffle()
    }
    
    func getNextWord() -> String {
        if currentIndex > words.count - 1 {
            currentIndex = 0
            words.shuffle()
        }
        currentIndex += 1
        return words[currentIndex - 1]
    }
}

extension Array {
    /** Randomizes the order of an array's elements. */
    mutating func shuffle() {
        for _ in 0..<10 {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}
