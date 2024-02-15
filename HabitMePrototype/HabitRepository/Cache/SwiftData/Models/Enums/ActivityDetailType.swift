//
//  ActivityDetailType.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/14/24.
//

import Foundation


enum ActivityDetailType: String, CaseIterable, Identifiable, Hashable, Codable {
    
    // Very important to have these exact rawValues because they are used to decode seed data
    case number = "Number"
    case text = "Text"
    
    var id: ActivityDetailType { self }
    
    
    var asset: BJAsset {
        switch self {
        case .number:
            BJAsset.numberSquare
        case .text:
            BJAsset.characterBubble
        }
    }
}
