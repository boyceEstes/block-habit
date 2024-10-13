//
//  ActivityDetailCalculationType+UI.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 4/29/24.
//

import Foundation
import HabitRepositoryFW


extension ActivityDetailCalculationType {
    
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
