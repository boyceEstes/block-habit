//
//  ContentView+HomeComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


extension ContentView {
    
    
    @ViewBuilder
    func makeHomeViewWithSheetyStackNavigation() -> some View {
        
        makeHomeViewWithSheetyNavigation()
            .flowNavigationDestination(flowPath: $homeNavigationFlowPath) { identifier in
                switch identifier {
                case let .habitDetail(habit):
                    makeHabitDetailViewWithSheetyNavigation(habit: habit)
                case .statistics:
                    makeStatisticsView()
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHomeViewWithSheetyNavigation() -> some View {
        
        makeHomeView()
            .sheet(item: $homeNavigationFlowDisplayedSheet) { identifier in
                
                switch identifier {
                case .createHabit:
                    makeCreateHabitViewWithSheetyNavigation()
                    
                case let .habitRecordDetail(habitRecord):
                    makeHabitRecordDetailView(habitRecord: habitRecord)
                    
                case let .editHabit(habit):
                    makeEditHabitView(habit: habit)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHomeView() -> some View {
        
        HomeView(
            goToHabitDetail: goToHabitDetailFromHome,
            goToCreateHabit: goToCreateHabitFromHome,
            goToHabitRecordDetail: goToHabitRecordDetailFromHome,
            goToEditHabit: goToEditHabitFromHome,
            goToStatistics: goToStatisticsFromHome
        )
    }
    
    
    // MARK: Push To Stack
    private func goToHabitDetailFromHome(habit: DataHabit) {
        
        homeNavigationFlowPath.append(.habitDetail(habit: habit))
    }
    
    
    // MARK: Display Sheet
    private func goToCreateHabitFromHome() {
        
        homeNavigationFlowDisplayedSheet = .createHabit
    }
    
    
    private func goToHabitRecordDetailFromHome(habitRecord: DataHabitRecord) {
        
        homeNavigationFlowDisplayedSheet = .habitRecordDetail(habitRecord: habitRecord)
    }
    
    
    private func goToEditHabitFromHome(habit: DataHabit) {
        
        homeNavigationFlowDisplayedSheet = .editHabit(habit: habit)
    }
    
    
    private func goToStatisticsFromHome() {
        
        homeNavigationFlowPath.append(.statistics)
    }
}
