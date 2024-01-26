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
                    makeHabitDetailView(habit: habit)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHomeViewWithSheetyNavigation() -> some View {
        
        makeHomeView()
            .sheet(item: $homeNavigationFlowDisplayedSheet) { identifier in
                
                switch identifier {
                case .createHabit:
                    makeCreateHabitView()
                case let .habitRecordDetail(habitRecord):
                    makeHabitRecordDetailView(habitRecord: habitRecord)
                }
            }
    }
    
    
    @ViewBuilder
    private func makeHomeView() -> some View {
        
        HomeView(
            goToHabitDetail: goToHabitDetailFromHome,
            goToCreateHabit: goToCreateHabitFromHome,
            goToHabitRecordDetail: goToHabitRecordDetailFromHome
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
}
