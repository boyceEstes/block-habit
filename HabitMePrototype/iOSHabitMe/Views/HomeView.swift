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


struct HomeView: View {
    
    @EnvironmentObject var habitController: HabitController
    
    // MARK: Injected Properties
    // Navigation & Actions
    let goToHabitDetail: (Habit) -> Void
    let goToCreateHabit: () -> Void
    let goToHabitRecordDetail: (HabitRecord) -> Void
    let goToEditHabit: (Habit) -> Void
    let goToStatistics: () -> Void
    let goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    let goToSettings: () -> Void
    // MARK: View Properties
    @State private var habitRecordVisualMode: HabitRecordVisualMode = .bar
    @State private var showDayDetail = false
    @Namespace private var animation

    
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
                    if !showDayDetail {
                        HScrollBarView(
                            graphWidth: screenWidth,
                            graphHeight: graphHeight,
                            numOfItemsToReachTop: 8,
                            habitRecordsForDays: habitRecordsForDays,
                            selectedDay: $habitController.selectedDay,
                            animation: animation,
                            showDayDetail: $showDayDetail,
                            destroyHabitRecord: { habitRecord in
                                habitController.destroyRecord(habitRecord)
                            }
                        )
                    } else {
                        DayDetailView(
                            destroyHabitRecord: { habitRecord in
                                habitController.destroyRecord(habitRecord)
                            },
                            goToHabitRecordDetail: goToHabitRecordDetail,
                            graphHeight: graphHeight,
                            numOfItemsToReachTop: 8,
                            habitRecords: habitController.habitRecordsForDays[habitController.selectedDay] ?? [HabitRecord.preview],
                            selectedDay: habitController.selectedDay,
                            animation: animation,
                            showDayDetail: $showDayDetail
                        )
                    }
                
                HabitsSection(
                    habitController: habitController,
                    goToHabitDetail: goToHabitDetail,
                    goToEditHabit: goToEditHabit,
                    goToCreateHabit: goToCreateHabit,
                    goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
                )
            }
            .background(Color.primaryBackground)
            .animation(.easeInOut(duration: 0.2), value: habitController.incompleteHabits)
        }
        .animation(.easeInOut(duration: 0.2), value: showDayDetail)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Text("\(currentStreak) 🔥")
                        .foregroundStyle(.primary)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    
                    
                    Text("\(completedNumberOfHabitsOnSelectedDay)/\(goalNumberOfHabitCompletionsOnSelectedDay) ⭐️")
                        .foregroundStyle(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
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
            }
        }
    }
    
    
    // MARK: Helper Logic
    
    
    // FIXME: Reevaluate when it is ready to consider scheduling habits for...
    // ...specific days
    //
    // Not considering specific days is also a problem, because we not get an accurate
    // goal whenever you are going back in time to a different day
    //
    // A good way to fix this would be to make a new property called `createdDate` on
    // the Habit. And we could detect whether or not the habit was made on that same day
    // and only then would we include it?
    //
    // Then also have the days that we want to display this habit for... This one will be
    // more complicated
    
    
    /**
     * The Daily Goal will be based on the number of habit records that you
     * need to create for a given day. This means that you will need to
     * account for the completionGoal of each habit.
     *
     * **NOTE**: This does not include tasks with no completion goal
     */
    var goalNumberOfHabitCompletionsOnSelectedDay: Int {
        
        habitController.isCompletedHabits
            .reduce(0) { partialResult, isCompletedHabit in
                
                guard let completionGoal = isCompletedHabit.habit.goalCompletionsPerDay else {
                    
                    // Do not include any habits without a completion goal in the count
                    return partialResult
                }
                
                guard let habitCreationDateAtNoon = isCompletedHabit.habit.creationDate.noon,
                      habitController.selectedDay >= habitCreationDateAtNoon else {
                    print("\(DateFormatter.shortDateShortTime.string(from: habitController.selectedDay)) <= habitCreateDateAtNoon: \(DateFormatter.shortDateShortTime.string(from: isCompletedHabit.habit.creationDate.noon!))")
                    // Do not include any habits without a completion goal in the count
                    return partialResult
                }

                
                return partialResult + completionGoal
            }
    }
    
    
    // FIXME: There is bit of an edge-case here if the user were to change their completion goals later it will show an inaccurate number
    /**
     * This number is calculated based on the number of records for the day.. Its occurring to me now that
     * this number could change if we were to change the completionGoal number later....
     *
     */
    var completedNumberOfHabitsOnSelectedDay: Int {
        habitController.habitRecordsForSelectedDay
            .reduce(0) { partialResult, habitRecord in
                guard habitRecord.habit.goalCompletionsPerDay != nil else {
                    // Do not include any habit records of habits with no completion goal in the count
                    return partialResult
                }
                
                // For each record, add 1
                return partialResult + 1
            }
    }
    
    
    /// Assuming today is the last day in habitsRecordsForDays
    var currentStreak: Int {
        
        StatisticsCalculator.findCurrentUsageStreak(for: habitController.habitRecordsForDays)
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
        .environmentObject(
            HabitController(
                blockHabitRepository: CoreDataBlockHabitStore.preview(),
                selectedDay: Date()
            )
        )
    }
}
