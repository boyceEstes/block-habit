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
    func makeHabitDetailViewWithSheetyNavigation(activity: DataHabit) -> some View {
        
        makeHabitDetailView(activity: activity)
            .sheet(item: $habitDetailNavigationFlowDisplayedSheet) { identifier in
                switch identifier {
                case let .editHabit(activity):
                    makeEditHabitView(habit: activity)
                case let .createActivityRecordWithDetails(activity, selectedDay):
                    makeCreateActivityRecordWithDetails(activity: activity, selectedDay: selectedDay)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHabitDetailView(activity: DataHabit) -> some View {
        
        HabitDetailView(
            activity: activity,
            goToEditHabit: { goToEditHabitFromHabitDetail(habit: activity) },
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
