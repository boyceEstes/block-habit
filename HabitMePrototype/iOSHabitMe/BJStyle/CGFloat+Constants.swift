//
//  CGFloat+Constants.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/9/24.
//

import Foundation


extension CGFloat {
    
    static let cornerRadius: CGFloat = 10
    /// cornerRadius for the top of a column on the BJBarView
    static let bigBlockCornerRadius: CGFloat = 4
    
    /// when you have a row, make this the to the next line
    static let vRowSubtitleSpacing: CGFloat = 6
    /// Space VStack sections of items
    static var vSectionSpacing: CGFloat = 20
    /// Space VStack items
    static var vItemSpacing: CGFloat = 12
    
    /// sections that are details in a larger section, there can be many and we want there to be less padding to get more on a page and not give it so much importance
    static var detailPadding: CGFloat = 12
}
