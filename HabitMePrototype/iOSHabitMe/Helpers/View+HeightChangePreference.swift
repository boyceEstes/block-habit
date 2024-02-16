//
//  View+HeightChangePreference.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/16/24.
//

import SwiftUI


extension View {
    
    @ViewBuilder
    func heightChangePreference(completion: @escaping (CGFloat) -> Void) -> some View {
        
        self.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizeKey.self, value: proxy.size.height)
                    .onPreferenceChange(SizeKey.self, perform: { value in
                        completion(value)
                    })
            }
        }
    }
}

