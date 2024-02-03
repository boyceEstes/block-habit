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
        
        case detailSelection(selectedDetails: Binding<[DataActivityDetail]>)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .detailSelection(value):
                hasher.combine(value.wrappedValue)
            }
        }
        
        
        static func == (lhs: CreateHabitNavigationFlow.StackIdentifier, rhs: CreateHabitNavigationFlow.StackIdentifier) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
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
            case let .detailSelection(selectedDetails):
                makeAddDetailSelectionView(selectedDetails: selectedDetails)
            }
        }
    }
    
    
    @ViewBuilder
    func makeCreateHabitView() -> some View {
        
        CreateHabitView(
            goToAddDetailsSelection: goToAddDetailsSelectionFromCreateHabit
        )
    }
    
    
    private func goToAddDetailsSelectionFromCreateHabit(selectedDetails: Binding<[DataActivityDetail]>) {
        
        createHabitNavigationFlowPath.append(.detailSelection(selectedDetails: selectedDetails))
    }
}



