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
        case createActivityRecordWithDetails(activity: DataHabit, selectedDay: Date)
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
                case let .createActivityRecordWithDetails(activity, selectedDay):
                    makeCreateActivityRecordWithDetails(activity: activity, selectedDay: selectedDay)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHabitDetailView(habit: DataHabit) -> some View {
        
        HabitDetailView(
            habit: habit,
            goToEditHabit: { goToEditHabitFromHabitDetail(habit: habit) },
            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetailsFromHabitDetail
        )
    }
    
    
    private func goToEditHabitFromHabitDetail(habit: DataHabit) {
        
        habitDetailNavigationFlowDisplayedSheet = .editHabit(habit: habit)
    }
    
    
    private func goToCreateActivityRecordWithDetailsFromHabitDetail(activity: DataHabit, selectedDay: Date) {
        
        habitDetailNavigationFlowDisplayedSheet = .createActivityRecordWithDetails(activity: activity, selectedDay: selectedDay)
    }
}
