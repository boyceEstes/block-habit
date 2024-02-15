//
//  LineChartActivityDetailData.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/8/24.
//

import Foundation


struct LineChartActivityDetailData: Identifiable {
    
    let id = UUID()
    let date: Date
    let value: Double

    
    // Charts aren't great with dates until they are converted to strings
    var displayableDate: String {
        guard let noonDate = date.noon else { return "" }
        return DateFormatter.shortDate.string(from: noonDate)
    }
}


extension Array where Element == LineChartActivityDetailData {
    
    // TODO: This will need to be thought out more to consider more edge cases
    func focusedDomainRange() -> ClosedRange<Int>? {
        
        let smallestValue = self.min {
            $0.value < $1.value
        }?.value
        
        let largestValue = self.max {
            $0.value < $1.value
        }?.value
        
        guard let smallestValue, let largestValue else { return nil }
        
        // This should keep the data more in the middle than on the edges
        let bufferOnTopAndBottom: Double = (largestValue - smallestValue) / 8
        
        print("Buffer on top and bottom: \(bufferOnTopAndBottom)")
        
        let bottomRangeValue = Int(floor(smallestValue - bufferOnTopAndBottom))
        let topRangeValue = Int(ceil(largestValue + bufferOnTopAndBottom))
        
        print("IS FOCUSED RANGE: \(bottomRangeValue)...\(topRangeValue)")
        return bottomRangeValue...topRangeValue
    }
}
