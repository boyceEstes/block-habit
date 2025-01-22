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
        case habitRecordDetail(habitRecord: HabitRecord)
        case createActivityRecordWithDetails(activity: Habit, selectedDay: Date, dismissAction: () -> Void)
        
        
        static func ==(lhs: SheetyIdentifier, rhs: SheetyIdentifier) -> Bool {
            
            switch (lhs, rhs) {
            case (.editHabit(let lhsHabit), .editHabit(let rhsHabit)):
                return lhsHabit == rhsHabit
            case (.habitRecordDetail(let lhsHabitRecord), .habitRecordDetail(let rhsHabitRecord)):
                return lhsHabitRecord == rhsHabitRecord
            case let (.createActivityRecordWithDetails(lhsHabit, lhsSelectedDay, _), .createActivityRecordWithDetails(rhsHabit, rhsSelectedDay, _ )):
                  // The dismissAction will not apply to equating the two sheetyIdentifiers, we will keep it simpler - should be fine
                return lhsHabit == rhsHabit && lhsSelectedDay == rhsSelectedDay
                  
            default: return false
            }
        }
        
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .editHabit(habit): hasher.combine(habit)
            case let .habitRecordDetail(habitRecord): hasher.combine(habitRecord)
            case let .createActivityRecordWithDetails(habit, selectedDay, dismissAction: _):
                hasher.combine(habit)
                hasher.combine(selectedDay)
            }
        }
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
                    
                case let .habitRecordDetail(habitRecord):
                    makeHabitRecordDetailView(activityRecord: habitRecord)
                    
                case let .createActivityRecordWithDetails(activity, selectedDay, dismissAction):
                    makeCreateActivityRecordWithDetails(activity: activity, selectedDay: selectedDay, dismissAction: dismissAction)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHabitDetailView(activity: Habit) -> some View {
        
        HabitDetailView(
            activity: activity,
            blockHabitStore: blockHabitStore,
            goToEditHabit: { goToEditHabitFromHabitDetail(habit: activity) },
            goToHabitRecordDetail: goToHabitRecordDetailFromHabitDetail,
            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetailsFromHabitDetail
        )
    }
    
    
    private func goToEditHabitFromHabitDetail(habit: Habit) {
        
        habitDetailNavigationFlowDisplayedSheet = .editHabit(habit: habit)
    }
    
    
    private func goToHabitRecordDetailFromHabitDetail(habitRecord: HabitRecord) {
        habitDetailNavigationFlowDisplayedSheet = .habitRecordDetail(habitRecord: habitRecord)
    }
    
    
    private func goToCreateActivityRecordWithDetailsFromHabitDetail(
        activity: Habit,
        selectedDay: Date,
        dismissAction: @escaping () -> Void
    ) {
        
        habitDetailNavigationFlowDisplayedSheet = .createActivityRecordWithDetails(activity: activity, selectedDay: selectedDay, dismissAction: dismissAction)
    }
}
