//
//  Utils.swift
//  FallingWordsSpriteKitAR
//
//  Created by Nathan Chan on 10/7/17.
//  Copyright © 2017 Nathan Chan. All rights reserved.
//

import Foundation

func getRandomFloat(between x: Float, and y: Float) -> Float {
    // x = -1.5, y = 1.5, diff = 3
    // x = 0, y = 2, diff = 2
    let diff = y - x
    return (Float(drand48()) * diff) + x
}

// This is a poorly named function
// But the goal is that we're trying to figure out the length of one side (not the longest side) of a right angle triangle, given the other two sides' lengths
func getRightTriangleSideLength(_ aShortSideLength: Float, _ theLongSideLength: Float) -> Float {
    // Pythagoreon theorem = a^2 + b^2 = c^2
    // solve for b, given a and c:
    // b = sqrt(c^2 - a^2)
    
    return sqrt(powf(theLongSideLength, 2) - powf(aShortSideLength, 2))
}

