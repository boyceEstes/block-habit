//
//  ActivityDetailType+UI.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation
import HabitRepositoryFW


extension ActivityDetailType {
    
    var asset: BJAsset {
        switch self {
        case .number:
            BJAsset.numberSquare
        case .text:
            BJAsset.characterBubble
        }
    }
}


