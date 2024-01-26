//
//  ContentView+HabitDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


extension ContentView {
    
    @ViewBuilder
    func makeHabitDetailView(habit: DataHabit) -> some View {
        
        HabitDetailView(habit: habit)
    }
}
