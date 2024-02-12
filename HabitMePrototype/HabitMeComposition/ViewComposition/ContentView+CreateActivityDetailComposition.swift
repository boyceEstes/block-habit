//
//  ContentView+CreateActivityDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/12/24.
//

import SwiftUI

extension ContentView {
    
    @ViewBuilder
    func makeCreateActivityDetailView() -> some View {
        
        // Placing in a navigation stack to place things in toolbar
        NavigationStack {
            CreateActivityDetailView()
        }
    }
}
