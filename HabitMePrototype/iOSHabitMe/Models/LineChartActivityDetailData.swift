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
