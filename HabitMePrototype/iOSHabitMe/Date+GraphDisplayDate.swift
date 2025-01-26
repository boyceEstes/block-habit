//
//  Date+GraphDisplayDate.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import SwiftUICore


extension Date {
    
    func displayDate(_ sizeCategory: DynamicTypeSize = .xxxLarge) -> String {
        
        
        let formatter: DateFormatter = sizeCategory.isAccessibilitySize ? .shortDateWithoutYear : .monthDayDate
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        
        switch self {
        case today:
            return "Today"
        case yesterday:
            
            if sizeCategory.isAccessibilitySize {
                fallthrough
            } else {
                return "Yesterday"
            }
            
        default:
            
            return formatter.string(from: self)
        }
    }
}
