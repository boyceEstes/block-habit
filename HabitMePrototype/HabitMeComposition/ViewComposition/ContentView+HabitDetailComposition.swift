//
//  ContentView+HabitDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import HabitRepositoryFW



class HabitDetailNavigationFlow: NewSheetyNavigationFlow {
    
    // MARK: - Properties
    @Published var displayedSheet: SheetyIdentifier?
    
    
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case editHabit(habit: Habit)
        case createActivityRecordWithDetails(activity: Habit, selectedDay: Date)
    }
}


extension ContentView {
    
    @ViewBuilder
    func makeHabitDetailViewWithSheetyNavigation(activity: Habit) -> some View {
        
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
    private func makeHabitDetailView(activity: Habit) -> some View {
        
        HabitDetailView(
            activity: activity,
            blockHabitStore: blockHabitStore,
            goToEditHabit: { goToEditHabitFromHabitDetail(habit: activity) },
            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetailsFromHabitDetail
        )
    }
    
    
    private func goToEditHabitFromHabitDetail(habit: Habit) {
        
        habitDetailNavigationFlowDisplayedSheet = .editHabit(habit: habit)
    }
    
    
    private func goToCreateActivityRecordWithDetailsFromHabitDetail(activity: Habit, selectedDay: Date) {
        
        habitDetailNavigationFlowDisplayedSheet = .createActivityRecordWithDetails(activity: activity, selectedDay: selectedDay)
    }
}
