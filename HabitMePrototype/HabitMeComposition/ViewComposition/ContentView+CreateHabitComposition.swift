//
//  ContentView+CreateHabitComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


class CreateEditHabitNavigationFlow: NewStackNavigationFlow {
    
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
        
        
        static func == (lhs: CreateEditHabitNavigationFlow.StackIdentifier, rhs: CreateEditHabitNavigationFlow.StackIdentifier) -> Bool {
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
        .flowNavigationDestination(flowPath: $createEditHabitNavigationFlowPath) { identifier in
            switch identifier {
            case let .detailSelection(selectedDetails):
                makeAddDetailsViewWithSheetyNavigation(selectedDetails: selectedDetails)
            }
        }
    }
    
    
    @ViewBuilder
    func makeCreateHabitView() -> some View {
        
        CreateHabitView(
            goToAddDetailsSelection: goToAddDetailsSelectionFromCreateEditHabit
        )
    }
    
    
    func goToAddDetailsSelectionFromCreateEditHabit(selectedDetails: Binding<[DataActivityDetail]>) {
        
        createEditHabitNavigationFlowPath.append(.detailSelection(selectedDetails: selectedDetails))
    }
}



