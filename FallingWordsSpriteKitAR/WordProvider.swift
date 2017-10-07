//
//  WordProvider.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/7/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import Foundation

var easy_word_dic = ["name": ["Aldo", "Clay", "Dan", "Ethan", "Gus", "Henry", "Angle", "Bay", "Kathy", "Kelly", "Lily", "Liza"],
                     "office": [],
                     "transportation": [],
                     "airport": [],
                     "shopping": []]

var advanced_word_dic = ["name": [],
                         "office": [],
                         "transportation": [],
                         "airport": [],
                         "shopping": []]

final class WordProvider {
    static let shared = WordProvider()
    private init() {
        words = ["apple", "dog", "banana", "cat", "zebra", "chair"]
        
        words.shuffle()
    }
    var words: [String]
    var currentIndex = 0
    
    func getNextWord() -> String {
        if currentIndex > words.count - 1 {
            currentIndex = 0
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
