//
//  SizeKey.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/16/24.
//

import SwiftUI

struct SizeKey: PreferenceKey {
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
