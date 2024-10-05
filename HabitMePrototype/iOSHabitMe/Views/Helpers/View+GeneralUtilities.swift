//
//  View+GeneralUtilities.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//

import SwiftUI

extension View {
    
    func hAlign(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}

