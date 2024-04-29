//
//  ContentView+HomeComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import HabitRepositoryFW


extension ContentView {
    
    
    @ViewBuilder
    func makeHomeViewWithSheetyStackNavigation(blockHabitStore: CoreDataBlockHabitStore) -> some View {
        
        makeHomeViewWithSheetyNavigation(blockHabitStore: blockHabitStore)
            .flowNavigationDestination(flowPath: $homeNavigationFlowPath) { identifier in
                switch identifier {
                case let .habitDetail(activity):
                    makeHabitDetailViewWithSheetyNavigation(activity: activity)
                case .statistics:
                    makeStatisticsView()
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHomeViewWithSheetyNavigation(blockHabitStore: CoreDataBlockHabitStore) -> some View {
        
        makeHomeView(blockHabitStore: blockHabitStore)
            .sheet(item: $homeNavigationFlowDisplayedSheet) { identifier in
                
                switch identifier {
                case .createHabit:
                    makeCreateHabitViewWithStackNavigation()
                    
                case let .createActivityRecordWithDetails(activity, selectedDay):
                    makeCreateActivityRecordWithDetails(activity: activity, selectedDay: selectedDay)
                    
                case let .habitRecordDetail(habitRecord):
                    makeHabitRecordDetailView(activityRecord: habitRecord)
                    
                case let .editHabit(habit):
                    makeEditHabitView(habit: habit)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHomeView(blockHabitStore: CoreDataBlockHabitStore) -> some View {
        
        HomeView(
            blockHabitStore: blockHabitStore,
            goToHabitDetail: goToHabitDetailFromHome,
            goToCreateHabit: goToCreateHabitFromHome,
            goToHabitRecordDetail: goToHabitRecordDetailFromHome,
            goToEditHabit: goToEditHabitFromHome,
            goToStatistics: goToStatisticsFromHome,
            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetailsFromHome
        )
    }
    
    
    // MARK: Push To Stack
    private func goToHabitDetailFromHome(habit: Habit) {
        
        homeNavigationFlowPath.append(.habitDetail(habit: habit))
    }
    
    
    // MARK: Display Sheet
    private func goToCreateHabitFromHome() {
        
        homeNavigationFlowDisplayedSheet = .createHabit
    }
    
    
    private func goToHabitRecordDetailFromHome(habitRecord: HabitRecord) {
        
        homeNavigationFlowDisplayedSheet = .habitRecordDetail(habitRecord: habitRecord)
    }
    
    
    private func goToEditHabitFromHome(habit: Habit) {
        
        homeNavigationFlowDisplayedSheet = .editHabit(habit: habit)
    }
    
    
    private func goToStatisticsFromHome() {
        
        homeNavigationFlowPath.append(.statistics)
    }
    
    
    private func goToCreateActivityRecordWithDetailsFromHome(activity: Habit, selectedDay: Date) {
        
        homeNavigationFlowDisplayedSheet = .createActivityRecordWithDetails(activity: activity, selectedDay: selectedDay)
    }
}
