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
//    @Environment(\.modelContext) var modelContext
//    @Query var dataHabits: [DataHabit]
//    @Query(sort: [
//        SortDescriptor(\DataActivityFilter.order, order: .forward)
//    ]) var activityFilterOptions: [DataActivityFilter]
    
    
    let goToHabitDetail: (Habit) -> Void
    let goToCreateHabit: () -> Void
    let goToHabitRecordDetail: (HabitRecord) -> Void
    let goToEditHabit: (Habit) -> Void
    let goToStatistics: () -> Void
    let goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    
    /*
     * So now the goal is to setup all of the data record stuff here from SwiftData.
     * The big problem is habitsOnDates is a little bit hairy. I wonder if it is better
     * for me to be able to query all of the datahabits and then deliver them to the
     * bar graphs... or maybe I should just decipher it here. This will be everything I should
     * have so I think it should be fine.
     */
//    @State private var viewModel: HomeViewModel
    @State private var habitRecordVisualMode: HabitRecordVisualMode = .bar
//    @State var selectedDay: Date = Date().noon!
    
    init(
        blockHabitStore: CoreDataBlockHabitStore,
        goToHabitDetail: @escaping (Habit) -> Void,
        goToCreateHabit: @escaping () -> Void,
        goToHabitRecordDetail: @escaping (HabitRecord) -> Void,
        goToEditHabit: @escaping (Habit) -> Void,
        goToStatistics: @escaping () -> Void,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void
    ) {
        self.goToHabitDetail = goToHabitDetail
        self.goToCreateHabit = goToCreateHabit
        self.goToHabitRecordDetail = goToHabitRecordDetail
        self.goToEditHabit = goToEditHabit
        self.goToStatistics = goToStatistics
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
        
        // FIXME: 2 GoToCreateActivityRecordsWithDetails
//        self._viewModel = State(
//            wrappedValue: HomeViewModel(
//                blockHabitStore: blockHabitStore,
//                goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
//            )
//        )
    }
    
    
    var body: some View {
//        let _ = print("Home View! '\(Self._printChanges())'")
//        let _ = print("issa sqlite: \(modelContext.sqliteCommand)")
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
//            let safeAreaInsetTop = proxy.safeAreaInsets.top
            let graphHeight = screenHeight * 0.4
//            let habitMenuHeight = screenHeight * 0.3
//            let itemHeight = graphHeight / 8
            
            VStack {
                
                switch habitRecordVisualMode {
                case .bar:
                    BarView(
                        graphWidth: screenWidth,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: 8,
                        habitRecordsForDays: habitController.habitRecordsForDays,
                        selectedDay: $habitController.selectedDay,
                        destroyHabitRecord: { habitRecord in
                            habitController.destroyRecord(habitRecord)
                        } // FIXME: 2 viewModel.destroyHabitRecord
                    )
                case .daily:
                    DayView(
                        destroyHabitRecord: { _ in }, // FIXME: 2 viewModel.destroyHabitRecord,
                        goToHabitRecordDetail: goToHabitRecordDetail,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: 8,
                        habitRecords: habitController.habitRecordsForDays[habitController.selectedDay] ?? [],
                        selectedDay: habitController.selectedDay
                    )
                }
                
                HabitsMenu(
                    goToHabitDetail: goToHabitDetail,
                    goToEditHabit: goToEditHabit,
                    habits: habitController.isCompletedHabits.sorted(by: { $0.habit.name < $1.habit.name }), //dataHabits/*filteredActivities*/,
                    didTapCreateHabitButton: {
                        goToCreateHabit()
                    }, didTapHabitButton: { habit in
//                         FIXME: 2 - viewModel.createHabitRecord(for: habit)
                        habitController.createRecordOrNavigateToRecordWithDetails(
                            for: habit,
                            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
                        )
                        print("record habit")
                    }, archiveHabit: { habit in
                        // FIXME: 2 - viewModel.archiveHabit(for: habit)
                        print("ARCHIVE HABIT")
                    }, destroyHabit: { habit in
                        // FIXME: 2 - viewModel.destroyHabit(for: habit)
                        print("DESTROY HABIT")
                    }
                )
//                VStack(spacing: .vSectionSpacing) {
//                    VStack(alignment: .leading, spacing: .vItemSpacing) {
//                        HStack {
//                            Text("Habits")
//                            Spacer()
//                            HStack(spacing: 16) {
//                                Button {
//                                    withAnimation {
//                                        isActivityFilterMenuShowing.toggle()
//                                    }
//                                } label: {
//                                    
//                                    Image(systemName: isActivityFilterMenuFilled ?  "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
//                                }
//                                Button {
//                                    goToCreateHabit()
//                                } label: {
//                                    Image(systemName: "plus.circle")
//                                }
//                            }
//                        }
//                        .homeDetailTitle()
//                        
//                        if isActivityFilterMenuShowing {
//                            HorizontalScrollySelectableList(items: $activityFilterOptions)
//                        }
//                    }
//                    
//                    HabitsMenu(
//                        goToHabitDetail: goToHabitDetail,
//                        goToEditHabit: goToEditHabit,
//                        habits: dataHabits,
//                        didTapCreateHabitButton: {
//                            goToCreateHabit()
//                        }, didTapHabitButton: { habit in
//                            createRecord(for: habit, in: modelContext)
//                        }
//                    )
//                }
            }
            .background(Color.primaryBackground)
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
                    
                    Text(displaySelectedDate)
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
    
//    
//    private func logRecord(for habit: DataHabit) {
//        
//        if !habit.activityDetails.isEmpty {
//            
//            goToCreateActivityRecordWithDetails(habit, selectedDay)
//            
//        } else {
//            
//            let (creationDate, completionDate) = ActivityRecordCreationPolicy.calculateDatesForRecord(on: selectedDay)
//            
//            modelContext.createHabitRecordOnDate(activity: habit, creationDate: creationDate, completionDate: completionDate)
//        }
//    }

    
    private func setHabitRecordViewMode(to visualMode: HabitRecordVisualMode) {
        
        withAnimation(.easeOut) {
            habitRecordVisualMode = visualMode
        }
    }
    
    
    private var displaySelectedDate: String {
        let formatter: DateFormatter = .shortDate
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        let twoDaysAgo = Date().noon!.adding(days: -2)
        let threeDaysAgo = Date().noon!.adding(days: -3)
        let fourDaysAgo = Date().noon!.adding(days: -4)
        
        switch habitController.selectedDay {
        case today:
            return "Today"
        case yesterday:
            return "Yesterday"
        case twoDaysAgo:
            return "2 Days Ago"
        case threeDaysAgo:
            return "3 Days Ago"
        case fourDaysAgo:
            return "4 Days Ago"
        default:
            return formatter.string(from: habitController.selectedDay)
        }
    }
    
    
    // FIXME: 2 Make sure that we are allowed to go to the previous day as long as we have the date available in our habitRecordsForDays
//    private var isAllowedToGoToPreviousDay: Bool {
//        
//        let calendar = Calendar.current
//        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon else { return false }
//        
//        return viewModel.selectedDay != startOf2024 ? true : false
//    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugged Dew",
        isArchived: false,
        color: Color.blue.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    let dataHabit2 = DataHabit(
        name: "Smashed Taco",
        isArchived: false,
        color: Color.orange.toHexString() ?? "#FFFFFF",
//        goalCompletionsPerDay: 1,
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    container.mainContext.insert(dataHabit2)
    
    let dataHabitRecord = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit
    )
    let dataHabitRecord2 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -2),
        habit: dataHabit
    )
    let dataHabitRecord3 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -2),
        habit: dataHabit
    )
    
    container.mainContext.insert(dataHabitRecord)
    container.mainContext.insert(dataHabitRecord2)
    container.mainContext.insert(dataHabitRecord3)
    
    
    let dataHabitRecord21 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: 0),
        habit: dataHabit2
    )
    let dataHabitRecord22 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit2
    )
    let dataHabitRecord23 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: dataHabit2
    )
    let dataHabitRecord24 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -2),
        habit: dataHabit2
    )
    
    container.mainContext.insert(dataHabitRecord21)
    container.mainContext.insert(dataHabitRecord22)
    container.mainContext.insert(dataHabitRecord23)
    container.mainContext.insert(dataHabitRecord24)
    
    
    return NavigationStack {
        HomeView(
            blockHabitStore: CoreDataBlockHabitStore.preview(),
            goToHabitDetail: { _ in },
            goToCreateHabit: { },
            goToHabitRecordDetail: { _ in },
            goToEditHabit: { _ in },
            goToStatistics: { },
            goToCreateActivityRecordWithDetails: { _, _ in }
        )
        .modelContainer(container)
    }
}
