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


struct HabitDetailView: View {

    @EnvironmentObject var habitController: HabitController
//    @State private var viewModel: HabitDetailViewModel
    let goToEditHabit: () -> Void
    let goToHabitRecordDetail: (HabitRecord) -> Void
    let goToCreateActivityRecordWithDetails: (Habit, Date, @escaping () -> Void) -> Void
    
    // Keeping a separate selectedDay here so that it does not impact the home screen when
    // this is dismissed
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Namespace private var animation
    
    @State var selectedDay: Date = Date().noon ?? Date()
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil

    @State private var showDayDetail: Bool = false
    @State private var activity: Habit
    @State private var habitRecordsForDays = [Date: [HabitRecord]]()
    @State private var cancellables = Set<AnyCancellable>()
    
    /// Does not show all of empty day logs
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
    
    
    let numOfItemsToReachTop = 5
    
    
    var totalRecords: String {
        
        "\(StatisticsCalculator.findTotalRecords(for: habitRecordsForDays))"
    }
    
    
    var avgRecordsPerDay: Double {
        StatisticsCalculator.findAverageRecordsPerDay(for: habitRecordsForDaysLogged)
    }
    
    
    var currentStreak: Int {
        StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: habitRecordsForDays)
    }
    
    var bestStreak: Int {
        StatisticsCalculator.findBestStreakInRecordsForHabit(for: habitRecordsForDays)
    }
    
    
    init(
        activity: Habit,
        blockHabitStore: CoreDataBlockHabitStore,
        goToEditHabit: @escaping () -> Void,
        goToHabitRecordDetail: @escaping (HabitRecord) -> Void,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date, @escaping () -> Void) -> Void
    ) {
        
        self._activity = State(initialValue: activity)
        
        self.goToEditHabit = goToEditHabit
        self.goToHabitRecordDetail = goToHabitRecordDetail
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
    }
    
    
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            let graphHeight = screenHeight * 0.3
            ScrollView {
                LazyVStack(spacing: .vSectionSpacing) {
                    // FIXME: Extract into a view where the user can tap to always go to day details view
                    HScrollBarView(
                        graphWidth: screenWidth,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: Double(numOfItemsToReachTop),
                        habitRecordsForDays: habitRecordsForDays,
                        selectedDay: $habitController.selectedDay,
                        animation: animation, 
                        showDayDetail: $showDayDetail
                    )
                    
                    HabitMePrimaryButton(title: "Log New Record", color: Color(hex: activity.color)) {
                        // FIXME: Update to have the CoreDataHabitBlockStore in this class before we can save
                        habitController.createRecordOrNavigateToRecordWithDetails(
                            for: activity,
                            goToCreateActivityRecordWithDetails: goToCreateActivityRecordWithDetails
                        )
                        // We would not have a dismiss closure here. But it does make ya wonder how we'll update it if we do it from here...
                        // It would not update the completed status of the object... So it looks like I need to pass some sort of completion
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
//                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10)
//                    )
//                    .padding([.horizontal])
                    
                    
                    activityDetailCharts
                        .padding(.horizontal)
                    
                    RecordDetailsForDaysList(
                        color: Color(hex: activity.color) ?? Color.blue,
                        goToHabitRecordDetail: goToHabitRecordDetail,
                        recordsForDays: habitRecordsForDaysLogged
                    )
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
        .onAppear {
            bindToLatestHabitInformation()
        }
        .onReceive(habitController.habitRecordsForDays(for: activity)) { receivedHabitRecordsForDays in
            print("BOYCE: Setting habitRecordsForDays in HabitDetail to \(receivedHabitRecordsForDays.count)")
            self.habitRecordsForDays = receivedHabitRecordsForDays
        }
    }
    
    
    // I made this a binding instead of an on-receive because I wanted to have the ability to
    // show an alert if some error popped up - if that's not a problem, just go with onReceive
    private func bindToLatestHabitInformation() {
        
        habitController.latestHabitInformation(for: activity)
            .sink { error in
                
                // FIXME: Log the error just to make sure that it is expected.
                // Lost the habit that we were looking for, it was probably deleted in the detail screen
                dismiss()
            } receiveValue: { receivedHabit in
                self.activity = receivedHabit
            }
            .store(in: &cancellables)
    }
    
    
    @ViewBuilder
    var activityDetailCharts: some View {
        
        let _ = print("BOYCE: \(allDetailChartDataSorted)")
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
                
                if !chartInfo.isEmpty {
                    ActivityDetailLineMarkChart(
                        data: chartInfo,
                        lineColor: Color(uiColor: UIColor(hex: activity.color) ?? .blue),
                        // Average should be more focused because there will probably be less variability
                        isFocusedDomain: activityDetail.calculationType == ActivityDetailCalculationType.average
                    )
                }
            }
            .sectionBackground()
        }
    }
    
    
    private func removeHabit() {
        
        DispatchQueue.main.async {
            habitController.deleteHabit(activity)
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
        .sectionBackground(padding: .detailPadding, color: .secondaryBackground)
    }
}


#Preview {
    
    let habit = Habit.mopTheCarpet

    return NavigationStack {
        
        HabitDetailView(
            activity: habit,
            blockHabitStore: CoreDataBlockHabitStore.preview(),
            goToEditHabit: { },
            goToHabitRecordDetail: { _ in },
            goToCreateActivityRecordWithDetails: { _, _, _ in }
        )
        .environmentObject(
            HabitController(
                blockHabitRepository: CoreDataBlockHabitStore.preview(),
                selectedDay: Date()
            )
        )
    }
}
