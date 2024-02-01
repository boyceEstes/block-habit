//
//  ContentView+CreateHabitComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


class CreateHabitNavigationFlow: NewSheetyNavigationFlow {
    
    // MARK: Properties
    var displayedSheet: SheetyIdentifier?
    
    // MARK: Sheety Identifiers
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case detailSelection
    }
}


extension ContentView {
    
    @ViewBuilder
    func makeCreateHabitViewWithSheetyNavigation() -> some View {
        
        // Placing in NavigationStack so that I can make sure that the `bottomBar` works
        // as expected (there was weird behavior with it disappearing after the sheet was
        // dismissed when this was not in a NavigationStack
        NavigationStack {
            makeCreateHabitView()
            
                .sheet(item: $createHabitNavigationFlowDisplayedSheet) { identifier in
                    switch identifier {
                    case .detailSelection:
                        makeAddDetailSelectionView()
                    }
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
        
        createHabitNavigationFlowDisplayedSheet = .detailSelection
    }
}



