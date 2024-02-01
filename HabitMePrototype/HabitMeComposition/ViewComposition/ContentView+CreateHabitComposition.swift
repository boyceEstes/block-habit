//
//  ContentView+CreateHabitComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


class CreateHabitNavigationFlow: NewStackNavigationFlow {
    
    // MARK: Properties
    @Published var path = [StackIdentifier]()
    
    // MARK: Stack Identifiers
    enum StackIdentifier: Hashable {
        
        case detailSelection
    }
}


extension ContentView {
    
    @ViewBuilder
    func makeCreateHabitViewWithSheetyNavigation() -> some View {
        
        // Placing in NavigationStack so that I can make sure that the `bottomBar` works
        // as expected (there was weird behavior with it disappearing after the sheet was
        // dismissed when this was not in a NavigationStack
        makeCreateHabitView()
        .flowNavigationDestination(flowPath: $createHabitNavigationFlowPath) { identifier in
            switch identifier {
            case .detailSelection:
                makeAddDetailSelectionView()
            }
        }
    }
    
    
    @ViewBuilder
    func makeCreateHabitView() -> some View {
        
        CreateHabitView(
            goToAddDetailsSelection: goToAddDetailsSelectionFromCreateHabit
        )
    }
    
    
    private func goToAddDetailsSelectionFromCreateHabit() {
        
        createHabitNavigationFlowPath.append(.detailSelection)
    }
}



