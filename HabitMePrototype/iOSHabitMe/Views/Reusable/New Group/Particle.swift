//
//  Particle.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/25.
//

import Foundation

struct Particle: Identifiable {
    
    let id = UUID()
    var randomX: CGFloat = 0
    var randomY: CGFloat = 0
    var scale: CGFloat = 1
    var opacity: CGFloat = 1
    
    
    mutating func reset() {
        
        randomX = 0
        randomY = 0
        scale = 1
        opacity = 1
    }
}
