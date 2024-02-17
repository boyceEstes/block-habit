//
//  ActivityDetailCalculationType.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/14/24.
//

import Foundation

enum ActivityDetailCalculationType: String, CaseIterable, Identifiable, Hashable, Codable  {
     
    case sum = "Sum"
    case average = "Average"
    
    var id: ActivityDetailCalculationType { self }
   
    var explanation: String {
        
        var _explanation: String = .calculationTypExplanation
        
        switch self {
        case .sum:
            _explanation.append("\n\n\(String.sumExplanation)")
        case .average:
            _explanation.append("\n\n\(String.avgExplanation)")
        }
        
        return _explanation
    }
    
    
    var displayPerDay: String {
        
        switch self {
        case .average:
            "Average per day"
        case .sum:
            "Total per day"
        }
    }
}
