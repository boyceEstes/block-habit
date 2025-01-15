//
//  ContentView+CreateHabitComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import HabitRepositoryFW


    
class CreateEditHabitNavigationFlow: NewStackNavigationFlow, NewSheetyNavigationFlow {
    
    // MARK: Properties
    @Published var path = [StackIdentifier]()
    @Published var displayedSheet: SheetyIdentifier?
    
    // MARK: Stack Identifiers
    enum StackIdentifier: Hashable {
        
//        case detailSelection(selectedDetails: Binding<[ActivityDetail]>, selectedColor: Color?)
        case scheduleSelection(schedulingUnits: Binding<ScheduleTimeUnit>, rate: Binding<Int>, scheduledWeekDays: Binding<Set<ScheduleDay>>, reminderTime: Binding<Date?>)
        
        func hash(into hasher: inout Hasher) {
            switch self {
//            case let .detailSelection(value, color):
//                hasher.combine(value.wrappedValue)
//                hasher.combine(color)
                
            case let .scheduleSelection(schedulingUnits, rate, scheduledWeekDays, reminderTime):
                hasher.combine(schedulingUnits.wrappedValue)
                hasher.combine(rate.wrappedValue)
                hasher.combine(scheduledWeekDays.wrappedValue)
                hasher.combine(reminderTime.wrappedValue)
            }
        }
        
        
        static func == (lhs: CreateEditHabitNavigationFlow.StackIdentifier, rhs: CreateEditHabitNavigationFlow.StackIdentifier) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }
    
    
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case detailSelection(selectedDetails: Binding<[ActivityDetail]>, selectedColor: Color?)
        
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .detailSelection(value, color):
                hasher.combine(value.wrappedValue)
                hasher.combine(color)
            }
        }
        
        
        static func ==(lhs: SheetyIdentifier, rhs: SheetyIdentifier) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
}


extension ContentView {
    
    @ViewBuilder
    func makeCreateHabitViewWithStackNavigation() -> some View {
        
        // Placing in NavigationStack so that I can make sure that the `bottomBar` works
        // as expected (there was weird behavior with it disappearing after the sheet was
        // dismissed when this was not in a NavigationStack
        makeCreateHabitView()
        .sheet(item: $createEditHabitNavigationFlowDisplayedSheet) { identifier in
            switch identifier {
            case let .detailSelection(selectedDetails, selectedColor):
                makeAddDetailsViewWithSheetyNavigation(selectedDetails: selectedDetails, selectedColor: selectedColor)
            }
        }
        .flowNavigationDestination(flowPath: $createEditHabitNavigationFlowPath) { identifier in
            switch identifier {
//                
//            case let .detailSelection(selectedDetails, selectedColor):
//                makeAddDetailsViewWithSheetyNavigation(selectedDetails: selectedDetails, selectedColor: selectedColor)
//                
            case let .scheduleSelection(schedulingUnits, rate, scheduledWeekDays, reminderTime):
                makeScheduleView(schedulingUnits: schedulingUnits, rate: rate, scheduledWeekDays: scheduledWeekDays, reminderTime: reminderTime)
            }
        }
    }
    
    
    @ViewBuilder
    func makeCreateHabitView() -> some View {
        
        CreateHabitView(
            blockHabitStore: blockHabitStore,
            goToAddDetailsSelection: goToAddDetailsSelectionFromCreateEditHabit,
            goToScheduleSelection: goToSchedulingSelectionFromCreateEditHabit
        )
    }
    
    
    func goToAddDetailsSelectionFromCreateEditHabit(selectedDetails: Binding<[ActivityDetail]>, selectedColor: Color?) {
        
        createEditHabitNavigationFlowDisplayedSheet = .detailSelection(selectedDetails: selectedDetails, selectedColor: selectedColor)
    }
    
    
    func goToSchedulingSelectionFromCreateEditHabit(schedulingUnits: Binding<ScheduleTimeUnit>, rate: Binding<Int>, scheduledWeekDays: Binding<Set<ScheduleDay>>, reminderTime: Binding<Date?>) {
        createEditHabitNavigationFlowPath.append(.scheduleSelection(schedulingUnits: schedulingUnits, rate: rate, scheduledWeekDays: scheduledWeekDays, reminderTime: reminderTime))
    }
}



