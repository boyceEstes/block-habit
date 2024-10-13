//
//  ActivityDetailSortable.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/23/24.
//

import Foundation


/// Conform to ActivityDetail objects in order to have built in functionality for whatever type of model is sorting them
/// - this was built because we had SwiftData sorting for activity details and independent model sorting, so this will reuse the same logic
public protocol ActivityDetailSortable {
    
    var name: String { get }
    var valueType: ActivityDetailType { get }
}


public extension Array where Element: ActivityDetailSortable {
    
    /// This is basically the same logic used in sorting the activity details as well
    func bjSort() -> [Element] {
        
        // Prioritize number types at the top
        // Sort alphabetically
        var sortedArray = [Element]()
        
        let numberActivityDetailRecords = filter { $0.valueType == .number }
        let sortedNumberActivityDetailRecords = numberActivityDetailRecords.sorted {
            $0.name < $1.name
        }
        
        let textActivityDetailRecords = filter {
            $0.valueType == .text
        }
        let sortedTextActivityDetailsRecords = textActivityDetailRecords.sorted {
            $0.name < $1.name
        }
        
        sortedArray.append(contentsOf: sortedNumberActivityDetailRecords)
        sortedArray.append(contentsOf: sortedTextActivityDetailsRecords)
        
        return sortedArray
    }
}
