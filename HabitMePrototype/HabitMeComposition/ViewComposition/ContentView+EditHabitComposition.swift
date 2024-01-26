//
//  ContentView+EditHabitComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/26/24.
//

import SwiftUI


extension ContentView {
    
    @ViewBuilder
    func makeEditHabitView(habit: DataHabit) -> some View {
        
        EditHabitView(habit: habit)
    }
}
