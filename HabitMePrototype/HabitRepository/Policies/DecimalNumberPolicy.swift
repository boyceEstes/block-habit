//
//  DecimalNumberPolicy.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/15/24.
//

import Foundation

final class DecimalNumberPolicy {
    
    private init() { }
    
    static func isValidDecimalNumber(numberString: String) -> Bool {
        
        var dotCount = 0
        for c in numberString {
            // Comma check is to cover for other languages that have comma decimals
            if String(c) == "." || String(c) == "," { dotCount += 1 }
        }
        
        return dotCount < 2
    }
}
