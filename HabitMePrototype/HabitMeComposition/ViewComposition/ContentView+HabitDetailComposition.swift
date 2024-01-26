//
//  ContentView+HabitDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI



class HabitDetailNavigationFlow: NewSheetyNavigationFlow {
    
    // MARK: - Properties
    @Published var displayedSheet: SheetyIdentifier?
    
    
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case editHabit(habit: DataHabit)
    }
}


extension ContentView {
    
    @ViewBuilder
    func makeHabitDetailViewWithSheetyNavigation(habit: DataHabit) -> some View {
        
        makeHabitDetailView(habit: habit)
            .sheet(item: $habitDetailNavigationFlowDisplayedSheet) { identifier in
                switch identifier {
                case let .editHabit(habit):
                    makeEditHabitView(habit: habit)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHabitDetailView(habit: DataHabit) -> some View {
        
        HabitDetailView(habit: habit, goToEditHabit: { goToEditHabitFromHabitDetail(habit: habit) } )
    }
    
    
    private func goToEditHabitFromHabitDetail(habit: DataHabit) {
        
        habitDetailNavigationFlowDisplayedSheet = .editHabit(habit: habit)
    }
}
