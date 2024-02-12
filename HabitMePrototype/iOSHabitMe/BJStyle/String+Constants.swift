//
//  String+Constants.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/10/24.
//

import Foundation


extension String {
    
    static let notAvailable = "N/A"
    
    
    // Calculation Type
    static let calculationTypExplanation = "Calculation type is used when combining multiple records over an interval of time.\n\n"
    static let sumExplanation = "'Sum' will add all of the detail records together over some amount of time. If you were reading for 30 min and then read again for 25 min, this would be displayed as 55 min."
    static let avgExplanation = "'Average' will average all of the detail records together over some amount of time. If you logged your weight in the morning for 190lbs and at night for 200lbs, this would be displayed as 195 lbs for the day"
}
