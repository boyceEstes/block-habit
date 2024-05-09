//
//  HabitDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/23/24.
//

import SwiftUI
import SwiftData
import HabitRepositoryFW


enum HabitDetailAlert {
    case deleteHabit(yesAction: () -> Void)
    
    func alertData() -> AlertDetail {
        
        switch self {
        case let .deleteHabit(yesAction):
            return AlertDetail.destructiveAlert(
                title: "Danger!",
                message: "This will delete all of the habit's associated records as well 👀. All those logs for have made for this will be gone... forever.",
                destroyTitle: "Destroy It All",
                destroyAction: yesAction
            )
        }
    }
}

import Combine

@Observable
class HabitDetailViewModel {
    
    let habit: Habit
    let blockHabitStore: CoreDataBlockHabitStore
    let habitRecordsByDateForHabitDataSource: HabitRecordsByDateDataSource
    
    var habitRecordsByDateForHabit = [Date: [HabitRecord]]()
    var cancellables = Set<AnyCancellable>()
    
    init(
        habit: Habit,
        blockHabitStore: CoreDataBlockHabitStore
    ) {
        self.habit = habit
        self.blockHabitStore = blockHabitStore
        
        do {
            self.habitRecordsByDateForHabitDataSource = try blockHabitStore.habitRecordsByDateForHabitDataSource(habit: habit)
        } catch {
            // FIXME: Be polite with the error
            fatalError("Could not load the habit records for the datasource '\(error)'")
        }
        
        bindHabitRecordsByDateForHabitDataSource()
    }
    
    
    private func bindHabitRecordsByDateForHabitDataSource() {
        
        habitRecordsByDateForHabitDataSource
            .habitRecordsByDate.sink { error in
                fatalError("BEEN A CRASH GETTING THE HABITRECORDS FOR HABIT TO DISPLAY PAGE DETAILS - '\(error)'")
            } receiveValue: { habitRecordsByDate in
                self.habitRecordsByDateForHabit = habitRecordsByDate
            }.store(in: &cancellables)
    }
}


struct HabitDetailView: View {

    @EnvironmentObject var habitController: HabitController
    @State private var viewModel: HabitDetailViewModel
    let activity: Habit
    let goToEditHabit: () -> Void
    let goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    
    // Keeping a separate selectedDay here so that it does not impact the home screen when
    // this is dismissed
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State var selectedDay: Date = Date().noon ?? Date()
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
//     Query to fetch all of the habit records for the habit
//    @Query(sort: [
//        SortDescriptor(\DataHabitRecord.completionDate, order: .reverse),
//        SortDescriptor(\DataHabitRecord.creationDate, order: .reverse)
//    ],
//        animation: .default
//    ) var dataHabitRecordsForHabit: [DataHabitRecord]
    
    
//    var filteredDatahabitRecordsForHabit: [DataHabitRecord] {
//        
//        dataHabitRecordsForHabit.filter {
//            
//            guard let habitForHabitRecord = $0.habit else { return false }
//            
//            let habitID = activity.id
//            return habitForHabitRecord.id == habitID
//        }
//    }
    
    var habitRecordsForDays: [Date: [HabitRecord]] {
        habitController.habitRecordsForDays(for: activity)
    }
    
    var habitRecordsForDaysLogged: [Date: [HabitRecord]] {
        habitRecordsForDays.filter {
            !$0.value.isEmpty
        }
    }
    
    
    // TODO: Unit test this
    // We are returning specific detail records associated with the detail because if we just looked at the detail's records,
    // we would get back the results for ALL activities that it has been associated with, instead of just this one.
    /// Translate activity records into usable activity detail data that can be iterated over to display chart information (Used as a piece of later computation)
    var chartActivityDetailRecordsForActivityRecords: [ActivityDetail: [ActivityDetailRecord]] {
        
        // Translate to dictionary of all of the activitydetails and all of the activity
        let habitRecords = habitRecordsForDays.values.flatMap { $0 }
        let uniqueHabitRecords = Set(habitRecords)
        
        return uniqueHabitRecords.reduce(into: [ActivityDetail: [ActivityDetailRecord]]()) { dict, activityRecord in
            
            for activityDetailRecord in activityRecord.activityDetailRecords {
                
                let activityDetail = activityDetailRecord.activityDetail
                guard activityDetail.valueType == .number else { continue } // Skip this record if the detail is not a number
                
                if dict[activityDetail] != nil {
                    dict[activityDetail]!.append(activityDetailRecord)
                } else {
                    dict[activityDetail] = [activityDetailRecord]
                }
            }
        }
    }
    
    /*
     * We need to get a date and value for each record and either combine or sum depending on the activity detail stat
     */

    
    /// Convert data to only dates and values for charts to consume, keyed by activity detail in order to set up each separate chart
    var allDetailChartData: [ActivityDetail: [LineChartActivityDetailData]] {
        
        // FIXME: Handle some details by averaging and some details by summing

        return chartActivityDetailRecordsForActivityRecords.reduce(into: [ActivityDetail: [LineChartActivityDetailData]]()) { allDetailDataDict, chartActivityDetailRecordsForActivityRecord in
            
            let (activityDetail, activityDetailRecords) = chartActivityDetailRecordsForActivityRecord
            
            var dateCountDictionary = [Date: (count: Int, amount: Double)]()
            
            for activityDetailRecord in activityDetailRecords {
                
                guard let activityDetailRecordValue = Double(activityDetailRecord.value),
                      let completionDate = activityDetailRecord.habitRecord?.completionDate.noon
                else {
                    // FIXME: Log if this happens, it really should never occur but shouldn't hurt anything if it skips
                    continue // If there is inconsistent data transforming a value, then continue on to the next row
                }

                // To average this, we will keep up with the count of records inserted for each date
                if let (currentRecordCountForDay, currentValueCountForDay) = dateCountDictionary[completionDate] {

                    switch activityDetailRecord.activityDetail.calculationType {
                    case .sum:
                        print("This activity detail, \(activityDetailRecord.activityDetail.name), is SUM")
                        dateCountDictionary[completionDate] = (1, currentValueCountForDay + activityDetailRecordValue)
                    case .average:
                        print("This activity detail is \(activityDetailRecord.activityDetail.name) is AVERAGE")
                        // must be average
                        let newCurrentCountForDay = currentRecordCountForDay + 1
                        let newCurrentValueForDay = (currentValueCountForDay + activityDetailRecordValue)

                        dateCountDictionary[completionDate] = (newCurrentCountForDay, newCurrentValueForDay)
                    }
                } else {
                    dateCountDictionary[completionDate] = (1, activityDetailRecordValue)
                }
            }

            let dateCountDictionaryArray = dateCountDictionary.sorted(by: { $0.key < $1.key })
            let data = dateCountDictionaryArray.map { LineChartActivityDetailData(date: $0.key, value: $0.value.amount / Double($0.value.count)) }
            
            
            allDetailDataDict[activityDetail] = data
        }
    }
    
    // Alphabetical order -> transforms into single tuple array
    /// Final iteration of transforming data to be used to display in chart
    var allDetailChartDataSorted: [(ActivityDetail, [LineChartActivityDetailData])] {
        
        allDetailChartData.sorted { $0.key.name < $1.key.name }
    }
    
    
    @State private var currentStreak = 0
    @State private var avgRecordsPerDay: Double = 0
    @State private var bestStreak = 0
    
    let numOfItemsToReachTop = 5
    
//    var datesWithHabitRecords: [Date: [DataHabitRecord]] {
//        
//        var _datesWithHabitRecords = [Date: [DataHabitRecord]]()
//        
//        print("update habit records by loading them")
//        
//        var calendar = Calendar.current
//        calendar.timeZone = .current
//        calendar.locale = .current
//        
//        guard let startOf2024 = DateComponents(calendar: calendar, year: 2024, month: 1, day: 1).date?.noon,
//              let today = Date().noon,
//              let days = calendar.dateComponents([.day], from: startOf2024, to: today).day
//        else { return [:] }
//        
//        
//        print("received from habitRepository fetch... \(filteredDatahabitRecordsForHabit.count)")
//        //
//        // Convert to a dictionary in order for us to an easier time in searching for dates
//        var dict = [Date: [DataHabitRecord]]()
//        // It is ordered from first date (jan. 1st) -> last date (today), the key is the last date in the streak
//        var streakingCount = 0
//        var lastStreakCount = 0
//        var maxStreakCount = 0
//        
//        // average records / day
//        /*
//         * NOTE: This is being calculated for only the days that the record is done.
//         * I think it would be demoralizing to see if you fell off and were trying to get back on
//         */
//        var daysRecordHasBeenDone = 0
//        var recordsThatHaveBeenDone = 0
//        
//        
//        for record in filteredDatahabitRecordsForHabit {
//            
//            guard let noonDate = record.completionDate.noon else { return [:] }
//            if dict[noonDate] != nil {
//                dict[noonDate]?.append(record)
//            } else {
//                dict[noonDate] = [record]
//            }
//        }
//        
//        
//        // Maybe for now, lets just start at january 1, 2024 for the beginning.
//        for day in 0...days {
//            // We want to get noon so that everything is definitely the exact same date (and we inserted the record dictinoary keys by noon)
//            guard let noonDate = calendar.date(byAdding: .day, value: day, to: startOf2024)?.noon else { return [:] }
//            
//            if let habitRecordsForDate = dict[noonDate] {
//                // graph logic
//                _datesWithHabitRecords[noonDate] = habitRecordsForDate
//                
//                daysRecordHasBeenDone += 1
//                recordsThatHaveBeenDone += habitRecordsForDate.count
//                
//                // streak logic
//                streakingCount += 1
//                
//            } else {
//                
//                _datesWithHabitRecords[noonDate] = []
//                // streak logic
//                if streakingCount >= maxStreakCount {
//                    maxStreakCount = streakingCount
//                }
//                lastStreakCount = streakingCount
//                streakingCount = 0
//            }
//        }
//        
//        // streak logic
//        if streakingCount > 0 {
//            // Streak has continued to today
//            if streakingCount >= maxStreakCount {
//                maxStreakCount = streakingCount
//            }
//            lastStreakCount = streakingCount
//        }
//        
//        DispatchQueue.main.async {
//            currentStreak = lastStreakCount
//            avgRecordsPerDay = Double(recordsThatHaveBeenDone) / Double(daysRecordHasBeenDone)
//            bestStreak = maxStreakCount
//        }
//        
//        
//        return _datesWithHabitRecords
//    }
    
    
    var totalRecords: String {
        return "-1"
        // FIXME: 2 - totalRecords
        // return "\(filteredDatahabitRecordsForHabit.count)"
    }
    
    
    init(
        activity: Habit,
        blockHabitStore: CoreDataBlockHabitStore,
        goToEditHabit: @escaping () -> Void,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void
    ) {
        
        self.activity = activity
        
        self._viewModel = State(
            wrappedValue: HabitDetailViewModel(
                habit: activity,
                blockHabitStore: blockHabitStore
            )
        )
        
        self.goToEditHabit = goToEditHabit
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
    }
    
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            let graphHeight = screenHeight * 0.3
            ScrollView {
                LazyVStack(spacing: .vSectionSpacing) {
                    // FIXME: BarView is broken until we can figure out a good way to get the statistics
                    BarView(
                        graphWidth: screenWidth,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: Double(numOfItemsToReachTop),
                        habitRecordsForDays: habitRecordsForDays,
                        selectedDay: $habitController.selectedDay,
                        destroyHabitRecord: { _ in
                            print("destroy last record logic")
                        }
                    )
                    
                    HabitMePrimaryButton(title: "Log New Record", color: Color(hex: activity.color)) {
                        // FIXME: Update to have the CoreDataHabitBlockStore in this class before we can save
                        habitController.createRecordOrNavigateToRecordWithDetails(
                            for: activity,
                            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
                        )
                    }
                    .padding(.horizontal)
                    
                    Grid() {
                        GridRow {
                            totalRecordsStatBox(totalRecords: totalRecords)
                            currentStreakStatBox(currentStreak: currentStreak)
                        }
                        GridRow {
                            avgRecordsPerDayStatBox(avgRecordsPerDay: avgRecordsPerDay)
                            bestStreakStatBox(bestStreak: bestStreak)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10)
                    )
                    .padding([.horizontal])
                    
                    
                    activityDetailCharts
                        .padding(.horizontal)
                    
                    LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
                        Text("Habit Records")
                            .font(.sectionTitle)
                        
                        ForEach(habitRecordsForDaysLogged.sorted(by: { $0.key > $1.key }), id: \.key) { day, records in
                            
                            Text("\(DateFormatter.shortDate.string(from: day))")
                            
                            ForEach(records, id: \.id) { record in
                                
                                VStack {
                                    ForEach(record.activityDetailRecords, id: \.id) { activityDetailRecord in
                                        
                                        HStack {
                                            Text("\(activityDetailRecord.activityDetail.name)")
                                            Spacer()
                                            Text("\(activityDetailRecord.value) \(activityDetailRecord.unit ?? "")")
                                        }
                                    }
                                }
                            }
                        }
                        // FIXME: 2 Orient this so that all the information is given
//                        Text("TO BE FIXED")
//                        if !filteredDatahabitRecordsForHabit.isEmpty {
//                            // FIXME: PUT THESE BACK!
//                            Text("To be fixed: Habit records - \(filteredDatahabitRecordsForHabit.count)")
                        
                        
//                        } else {
//                            Text("No records found for this activity yet")
//                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.primaryBackground)
        .navigationTitle("\(activity.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                Button {
                    goToEditHabit()
                } label: {
                    Image(systemName: "pencil.circle")
                }
                
                Button(role: .destructive) {
                    print("Destroy the garbage")
                    showAlert = true
                    alertDetail = HabitDetailAlert.deleteHabit(yesAction: removeHabit).alertData()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
    }
    
    
    @ViewBuilder
    var activityDetailCharts: some View {
        
        // loops over activitydetails to display one chart at a time
        ForEach(allDetailChartDataSorted, id: \.0) { chartInformation in
            
            let (activityDetail, chartInfo) = chartInformation
            
            VStack(alignment: .leading, spacing: .vSectionSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(activityDetail.name)")
                    Spacer()
                    Text("\(activityDetail.calculationType.displayPerDay)")
                        .font(Font.rowDetail)
                        .foregroundStyle(Color.secondaryFont)
                }
                
                ActivityDetailLineMarkChart(
                    data: chartInfo,
                    lineColor: Color(uiColor: UIColor(hex: activity.color) ?? .blue),
                    // Average should be more focused because there will probably be less variability
                    isFocusedDomain: activityDetail.calculationType == ActivityDetailCalculationType.average
                )
            }
            .sectionBackground()
        }
    }
    
    
    private func removeHabit() {
        
        DispatchQueue.main.async {
            dismiss()
            // FIXME: Delete/Archive accounting that we do not have a SwiftData model
            print("'Delete' the habit from detail view")
//            modelContext.delete(habit: activity)
        }
    }
    
    
    private func totalRecordsStatBox(totalRecords: String) -> some View {
        StatBox(title: "Total Records", value: totalRecords)
    }

    private func currentStreakStatBox(currentStreak: Int) -> some View {
        
        if currentStreak == 1 {
            StatBox(title: "Current Streak", value: "\(currentStreak)", units: "day")
        } else {
            StatBox(title: "Current Streak", value: "\(currentStreak)", units: "days")
        }
    }
    
    private func avgRecordsPerDayStatBox(avgRecordsPerDay: Double) -> some View {
        let title = "Average Records / Day"
        if avgRecordsPerDay > 0 {
            return StatBox(title: title, value: String(format: "%.2f", avgRecordsPerDay), units: "rpd")
        } else {
            return StatBox(title: title, value: "N/A")
        }

    }
    
    private func bestStreakStatBox(bestStreak: Int) -> some View {
        if bestStreak == 1 {
            return StatBox(title: "Best Streak", value: "\(bestStreak)", units: "day")
        } else {
            return StatBox(title: "Best Streak", value: "\(bestStreak)", units: "days")
        }
    }
}


struct TextWithUnits: View {
    
    let text: String
    let units: String?
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(text)
                .font(.title2)
                .fontWeight(.semibold)
            if let units {
                Text(units)
                    .font(.callout)
            }
        }
    }
}

extension View {
    
    func statTitle() -> some View {
        modifier(StatTitle())
    }
}

struct StatTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .lineLimit(2, reservesSpace: true)
            .multilineTextAlignment(.center)
    }
}


struct StatBox: View {
    
    let title: String
    let value: String
    let units: String?
    let subValue: String?
    let subValueColor: Color?
    
    init(title: String, value: String, units: String? = nil, subValue: String? = nil, subValueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.units = units
        self.subValue = subValue
        self.subValueColor = subValueColor
    }
    
    
    var body: some View {
            
        VStack(spacing: 0) {
            Text(title)
                .statTitle()
            
            TextWithUnits(text: value, units: units)
            
            if let subValue {
                Text(subValue)
                    .font(.footnote)
                    .foregroundStyle(subValueColor == nil ? Color(uiColor: .secondaryLabel) : subValueColor!)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .sectionBackground(padding: .detailPadding, color: .tertiaryBackground)
    }
}


#Preview {
    
    let habit = Habit.preview
    // FIXME: Remove unnecessary preview setup since moving to independent model methodology
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        name: "Chugging Dew",
        isArchived: false,
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    

    let dataHabitRecord0 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: 0),
        habit: dataHabit
    )
    let dataHabitRecord00 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: 0),
        habit: dataHabit
    )
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

    container.mainContext.insert(dataHabitRecord0)
    container.mainContext.insert(dataHabitRecord00)
    container.mainContext.insert(dataHabitRecord)
    container.mainContext.insert(dataHabitRecord2)
    container.mainContext.insert(dataHabitRecord3)
    
    
    let dataHabitRecord4 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -8),
        habit: dataHabit
    )
    let dataHabitRecord5 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -9),
        habit: dataHabit
    )
    let dataHabitRecord6 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -10),
        habit: dataHabit
    )
    let dataHabitRecord7 = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -11),
        habit: dataHabit
    )
    
    container.mainContext.insert(dataHabitRecord4)
    container.mainContext.insert(dataHabitRecord5)
    container.mainContext.insert(dataHabitRecord6)
    container.mainContext.insert(dataHabitRecord7)
    
    return NavigationStack {
        HabitDetailView(
            activity: habit,
            blockHabitStore: CoreDataBlockHabitStore.preview(),
            goToEditHabit: { },
            goToCreateActivityRecordWithDetails: { _, _ in }
        )
        .modelContainer(container)
    }
}
