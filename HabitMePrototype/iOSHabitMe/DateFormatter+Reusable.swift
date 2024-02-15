//
//  DateFormatter+Reusable.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/24/24.
//

import Foundation


extension DateFormatter {
    
    /// Ex: (depending on locale) `1/1/24`
    static let shortDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    
    /// Ex `1/1`, `12/25` or `01/01`, `25/12` if you are in other countries
    static let shortDateWithoutYear: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter
    }()
    
    
    /// Ex: `Jan 1`, `Dec 25` or `1 Jan`, `25 Dec` if you are in other countries
    static let monthDayDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter
    }()
    
    
    /// Ex: (depending on locale) `1:34 PM`
    static let shortTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    /// Ex: (depending on locale) `1/1/24, 1:12 PM`
    static let shortDateShortTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
