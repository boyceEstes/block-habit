//
//  HomeView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import SwiftData
import HabitRepositoryFW


enum HabitRecordVisualMode {
    case bar
    case daily
}


//struct ActivityMenuFilter: SelectableListItem {
//    
//    let activityMenuFilterType: ActivityMenuFilterType
//    var isSelected: Bool
//    
//    
//    var id: String {
//        name
//    }
//
//    var name: String {
//        activityMenuFilterType.name
//    }
//}


//extension DataHabit {
//    
//    func isActivityComplete(activityRecords: [DataHabitRecord]) -> Bool {
//        
//        if let completionGoal = goalCompletionsPerDay {
//            let recordCountForHabit = activityRecords.reduce(0) { partialResult, activityRecord in
//                if activityRecord.habit == self { return partialResult + 1 }
//                else { return partialResult }
//            }
//            
//            return recordCountForHabit >= completionGoal
//        } else {
//            // It can never be complete
//            return false
//        }
//    }
//}


struct HomeView: View {
    
    @EnvironmentObject var habitController: HabitController
    
    let goToHabitDetail: (Habit) -> Void
    let goToCreateHabit: () -> Void
    let goToHabitRecordDetail: (HabitRecord) -> Void
    let goToEditHabit: (Habit) -> Void
    let goToStatistics: () -> Void
    let goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    let goToSettings: () -> Void
    
    @State private var habitRecordVisualMode: HabitRecordVisualMode = .bar
    
    init(
        blockHabitStore: CoreDataBlockHabitStore,
        goToHabitDetail: @escaping (Habit) -> Void,
        goToCreateHabit: @escaping () -> Void,
        goToHabitRecordDetail: @escaping (HabitRecord) -> Void,
        goToEditHabit: @escaping (Habit) -> Void,
        goToStatistics: @escaping () -> Void,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void,
        goToSettings: @escaping () -> Void
    ) {
        self.goToHabitDetail = goToHabitDetail
        self.goToCreateHabit = goToCreateHabit
        self.goToHabitRecordDetail = goToHabitRecordDetail
        self.goToEditHabit = goToEditHabit
        self.goToStatistics = goToStatistics
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
        self.goToSettings = goToSettings
    }
    
    
    var habitRecordsForDays: [Date: [HabitRecord]] {
        
        return habitController.habitRecordsForDays
    }
    
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            let graphHeight = screenHeight * 0.4
            
            VStack {
                
                switch habitRecordVisualMode {
                case .bar:
                    BarView(
                        graphWidth: screenWidth,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: 8,
                        habitRecordsForDays: habitRecordsForDays,
                        selectedDay: $habitController.selectedDay,
                        destroyHabitRecord: { habitRecord in
                            habitController.destroyRecord(habitRecord)
                        }
                    )
                case .daily:
                    DayView(
                        destroyHabitRecord: { habitRecord in
                            habitController.destroyRecord(habitRecord)
                        },
                        goToHabitRecordDetail: goToHabitRecordDetail,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: 8,
                        habitRecords: habitController.habitRecordsForDays[habitController.selectedDay] ?? [],
                        selectedDay: habitController.selectedDay
                    )
                }
                
                HabitsMenu(
                    completedHabits: habitController.completeHabits,
                    incompletedHabits: habitController.incompleteHabits,
                    goToHabitDetail: goToHabitDetail,
                    goToEditHabit: goToEditHabit,
                    didTapCreateHabitButton: {
                        goToCreateHabit()
                    }, didTapHabitButton: { habit in
//                         FIXME: 2 - viewModel.createHabitRecord(for: habit)
                        habitController.createRecordOrNavigateToRecordWithDetails(
                            for: habit,
                            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
                        )
                    }, archiveHabit: { habit in
                        
                        habitController.archiveHabit(habit)
                    }
                )
            }
            .background(Color.primaryBackground)
            .animation(.easeInOut(duration: 0.2), value: habitController.incompleteHabits)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button {
                        habitController.goToPrevDay()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                    // FIXME: 2 See more at the definition for that
                    .disabled(habitController.isAllowedToGoToPrevDay() ? false : true)
                    
                    Text(habitController.selectedDay.displayDate)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button {
                        habitController.goToNextDay()
                    } label: {
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                    }
                    .disabled(habitController.isAllowedToGoToNextDay() ? false : true)
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                Button {
                    goToSettings()
                } label : {
                    Image(systemName: "gear")
                }
                
                Button {
                    goToStatistics()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                }
                
                // TODO: Some logic to dictate whether it is a bar button or a daily log button
                switch habitRecordVisualMode {
                case .bar:
                    // Daily button
                    Button {
                        setHabitRecordViewMode(to: .daily)
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .fontWeight(.semibold)
                    }
                case .daily:
                    // Chart button
                    Button {
                        setHabitRecordViewMode(to: .bar)
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    
    private func setHabitRecordViewMode(to visualMode: HabitRecordVisualMode) {
        
        withAnimation(.easeOut) {
            habitRecordVisualMode = visualMode
        }
    }
}


#Preview {

    return NavigationStack {
        HomeView(
            blockHabitStore: CoreDataBlockHabitStore.preview(),
            goToHabitDetail: { _ in },
            goToCreateHabit: { },
            goToHabitRecordDetail: { _ in },
            goToEditHabit: { _ in },
            goToStatistics: { },
            goToCreateActivityRecordWithDetails: { _, _ in },
            goToSettings: { }
        )
    }
}
