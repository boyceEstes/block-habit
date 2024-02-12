//
//  ContentView+AddDetailSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/31/24.
//

import SwiftUI


class AddDetailsNavigationFlow: NewSheetyNavigationFlow {
    
    // MARK: Properties
    @Published var displayedSheet: SheetyIdentifier?
    
    // MARK: Sheety Identifier
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case createActivityDetail
    }
}


extension ContentView {
    
    
    @ViewBuilder
    func makeAddDetailsViewWithSheetyNavigation(selectedDetails: Binding<[DataActivityDetail]>) -> some View {
        
        makeAddDetailsView(selectedDetails: selectedDetails)
            .sheet(item: $addDetailsNavigationFlowDisplayedSheet) { identifier in
                switch identifier {
                case .createActivityDetail:
                    makeCreateActivityDetailView()
                }
            }
    }
    
    
    @ViewBuilder
    func makeAddDetailsView(selectedDetails: Binding<[DataActivityDetail]>) -> some View {
        
        AddDetailsView(
            selectedDetails: selectedDetails,
            goToCreateActivityDetail: goToCreateActivityDetailFromAddDetailSelection
        )
    }
    
    
    private func goToCreateActivityDetailFromAddDetailSelection() {
        
        addDetailsNavigationFlowDisplayedSheet = .createActivityDetail
    }
}


