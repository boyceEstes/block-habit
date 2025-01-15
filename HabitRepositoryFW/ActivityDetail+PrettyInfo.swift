//
//  ActivityDetail+PrettyInfo.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/15/25.
//

import Foundation


public extension ActivityDetail {
    
    func prettyUnits() -> String {
        
        switch valueType {
        case .number:
            if let units = availableUnits,
               !units.isEmpty {
                return "in \(units)"
            } else {
                return ""
            }
        case .text:
            return ""
        }
    }
}
