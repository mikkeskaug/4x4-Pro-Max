//
//  IntervalStruct.swift
//  4x4 Pro Max
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import Foundation

enum IntervalType: String {
    case warmup = "Warm-up"
    case run = "Run"
    case jog = "Jog"
    case cooldown = "Cooldown"
}

struct WorkoutInterval {
    let type: IntervalType
    let name: String
    let duration: TimeInterval // in seconds
    
}
