//
//  DateFormatter+Reusable.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/24/24.
//

import Foundation


extension DateFormatter {
    
    static let shortDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    
    static let shortTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    static let shortDateShortTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
