//
//  ContentView+SettingsComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 5/14/24.
//

import SwiftUI


//class SettingsNavigationFlow: NewStackNavigationFlow {
//    
//    // MARK: Properties
//    @Published var path = [StackIdentifier]()
//    
//    // MARK: Stack Identifiers
//    enum StackIdentifier: Hashable {
//        
//        case notifications
//        case archivedHabits
//        case archivedActivityDetails
//        
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(self)
////            switch self {
////            case notifications:
////            case archivedHabits:
////            case archivedActivityDetails:
////            }
//        }
//        
//        
//        static func == (lhs: SettingsNavigationFlow.StackIdentifier, rhs: SettingsNavigationFlow.StackIdentifier) -> Bool {
//            lhs.hashValue == rhs.hashValue
//        }
//    }
//}


extension ContentView {
    
    
    @ViewBuilder
    func makeSettingsView() -> some View {
        
        SettingsView(
            goToNotifications: goToNotificationsFromSettings,
            goToArchivedHabits: goToArchivedHabitsFromSettings,
            goToArchivedActivityDetails: goToArchivedActivityDetailsFromSettings,
            goToLetsTalk: goToLetsTalkFromSettings,
            goToBuyMeACoffee: goToBuyMeACoffeeFromSettings
        )
    }
    
    
    func goToNotificationsFromSettings() {
        homeNavigationFlowPath.append(.notifications)
    }
    
    func goToArchivedHabitsFromSettings() {
        homeNavigationFlowPath.append(.archivedHabits)
    }
    
    func goToArchivedActivityDetailsFromSettings() {
        homeNavigationFlowPath.append(.archivedActivityDetails)
    }
    
    func goToLetsTalkFromSettings() {
        homeNavigationFlowPath.append(.letsTalk)
    }
    
    func goToBuyMeACoffeeFromSettings() {
        homeNavigationFlowPath.append(.buyMeACoffee)
    }
    
    
    // MARK: Settings-Specific Views that may need to be extracted later
    @ViewBuilder
    func makeNotificationSettingsView() -> some View {
        
        NotificationSettingsView()
    }
    
    @ViewBuilder
    func makeArchivedHabitsView() -> some View {
        
        ArchivedHabitsView()
    }
    
    @ViewBuilder
    func makeArchivedActivityDetailsView() -> some View {
        
        ArchivedActivityDetailsView()
    }
    
    @ViewBuilder
    func makeGoToLetsTalkView() -> some View {
        
        LetsTalkView()
    }
    
    
    @ViewBuilder
    func makeGoToBuyMeACoffeeView() -> some View {
        
        DonationView()
    }
}
