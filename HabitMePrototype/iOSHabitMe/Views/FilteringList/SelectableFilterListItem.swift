//
//  SelectableFilterListItem.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import SwiftUI


// Needs to be Identifiable for the foreach conformance, just makes it easier
protocol SelectableListItem: Identifiable, Hashable {
    
    var id: String { get } // Id stays the same
    var name: String { get } // Name stays the same
    var isSelected: Bool { get set } // Gets toggled
    var color: Color { get }
}


//extension SelectableListItem {
//    
//    var color: Color {
//        
//        let defaultColor = Color.blue
//        
//        guard let colorString, let unwrappedColor = Color(hex: colorString) else {
//            return defaultColor
//        }
//        
//        return unwrappedColor
//    }
//}
