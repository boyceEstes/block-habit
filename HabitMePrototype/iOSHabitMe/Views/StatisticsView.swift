//
//  StatisticsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/27/24.
//

import SwiftUI
import SwiftData
import HabitRepositoryFW

/*
 * To keep things as simple as I can think, I would want to keep this on the Home Screen and use
 * the existing Bar view on that screen. Interact with that bar view by tapping on filters which
 * would update the stats that will be displayed in this view.
 */

struct SelectableHabit: Hashable, SelectableListItem {

    let id: String
    let name: String
    var isSelected: Bool = true
    var colorString: String?
    
    // This is kept for easily keeping data that will be needed later
    var habit: Habit
    
    init(habit: Habit) {
        self.id = habit.id
        self.name = habit.name
        self.colorString = habit.color 
        self.habit = habit
    }
}

struct StatisticsView: View {
    
    @EnvironmentObject var habitController: HabitController
    
    /// We are filtering on the habits that are selectable (which are built from the dataHabits query - other than setting up the selectableHabits, `dataHabits` should never be used
    private var selectedHabits: [Habit] {
        let allSelectedHabits = selectableHabits.filter { $0.isSelected }.map { $0.habit }
        return allSelectedHabits
    }
    
    private var selectedHabitRecordsForDays: [Date: [HabitRecord]] {
        
        habitController.habitRecordsForDays.mapValues { $0.filter { selectedHabits.contains($0.habit) } }
    }
    
    @State private var selectableHabits = [SelectableHabit]()
    
    // Basic stats
    private var totalRecords: Int {
        return StatisticsCalculator.findTotalRecords(for: selectedHabitRecordsForDays)
    }
    
    private var avgRecordsPerDay: Double {
        
        return StatisticsCalculator.findAverageRecordsPerDay(for: selectedHabitRecordsForDays)
    }
    
    private var mostCompletions: (recordCount: Int, habit: Habit)? {
        
        guard let (mostCompletionsHabit, mostCompletionsCount) = StatisticsCalculator.findHabitWithMostCompletions(for: selectedHabitRecordsForDays, with: selectedHabits) else {
            return nil
        }
        
        return (mostCompletionsCount, mostCompletionsHabit)
    }
    
    
    private var bestStreak: (HabitWithCount)? {
        
        guard let bestStreaks = StatisticsCalculator.findHabitWithBestStreak(for: selectedHabitRecordsForDays, with: selectedHabits) else {
            return nil
        }
        
        return (bestStreaks.habit, bestStreaks.count)
    }
    
    
    private var totalDays: Int {
        StatisticsCalculator.findTotalDays(for: selectedHabitRecordsForDays)
    }
    
    
    var body: some View {
        
        GeometryReader { proxy in
            ScrollView {
            
                let screenWidth = proxy.size.width
                let screenHeight = proxy.size.height
                let graphHeight = screenHeight * 0.3

                VStack(spacing: 0) {
                    // FIXME: Statistics is broken until further notice
                    StatisticsBarView(
                        graphWidth: screenWidth,
                        graphHeight: graphHeight,
                        numOfItemsToReachTop: 12,
                        datesWithHabitRecords: selectedHabitRecordsForDays
                    )
                    .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if !selectableHabits.isEmpty {
                            HStack {
                                Text("Habits")
                                    .font(.title3)
                                
                                Spacer()
                                
                                Button("Reset") {
                                    for i in 0..<selectableHabits.count {
                                        selectableHabits[i].isSelected = true
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            
                            HorizontalScrollySelectableList(items: $selectableHabits)
                        }
                    }
                    
                    
                    Grid(alignment: .topLeading) {
                        
                        GridRow {
                            StatBox(title: "Total Records", value: "\(totalRecords)")
                                .gridCellColumns(3)
                            StatBox(title: "Total Days", value: "\(totalDays)")
                                .gridCellColumns(2)
                            StatBox(title: "Average per Day", value: String(format: "%.2f", avgRecordsPerDay))
                                .gridCellColumns(3)
                        }
                        
                        GridRow {
                            if let mostCompletions {
                                StatBox(title: "Most Completions", value: "\(mostCompletions.recordCount)", units: "records", subValue: "\(mostCompletions.habit.name)", subValueColor: Color(hex: mostCompletions.habit.color))
                                    .gridCellColumns(4)
                            } else {
                                StatBox(title: "Most Completions", value: "N/A")
                                    .gridCellColumns(4)
                            }
                            
                            
                            if let bestStreak {
                                StatBox(title: "Best Streak", value: "\(bestStreak.count)", units: "days", subValue: "\(bestStreak.habit.name)", subValueColor: Color(hex: bestStreak.habit.color))
                                    .gridCellColumns(4)
                            } else {
                                StatBox(title: "Best Streak", value: "N/A")
                                    .gridCellColumns(4)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                }
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupSelectableHabits()
//            calculateDatesWithHabitRecords()
        }
//        .onChange(of: selectedHabits) {
//            selectedHabitRecords = dataHabitRecords.filter { habitRecord in
//                guard let habitForHabitRecord = habitRecord.habit else { return false }
//                return selectedHabits.contains(habitForHabitRecord)
//            }
//            
////            calculateDatesWithHabitRecords()
        
    }
    
    
    private func setupSelectableHabits() {
        
        print("setup for selectable habits happens")
        selectableHabits = habitController.isCompletedHabits.map { SelectableHabit(habit: $0.habit) }
        
//        selectedHabitRecords = dataHabitRecords.filter { habitRecord in
//            guard let habitForHabitRecord = habitRecord.habit else { return false }
//            return selectedHabits.contains(habitForHabitRecord)
        }
    }
    



// Needs to be Identifiable for the foreach conformance, just makes it easier
protocol SelectableListItem: Identifiable {
    
    var id: String { get } // Id stays the same
    var name: String { get } // Name stays the same
    var isSelected: Bool { get set } // Gets toggled
    
    var colorString: String? { get }
}


extension SelectableListItem {
    
    var color: Color {
        
        let defaultColor = Color.blue
        
        guard let colorString, let unwrappedColor = Color(hex: colorString) else {
            return defaultColor
        }
        
        return unwrappedColor
    }
}


struct HorizontalScrollySelectableList<T: SelectableListItem>: View {
    
    @Binding var items: [T]
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(0..<items.count, id: \.self) { i in
                    
                    let item = items[i]
                    let isSelected = item.isSelected
                    let name = item.name
                    let color = item.color
                    
                    Button {
                        print("tapped selectableHabit")
                        withAnimation {
                            items[i].isSelected.toggle()
                        }
                    } label: {
                        Text("\(name)")
                            .foregroundStyle(Color.primary)
                    }
                    .padding(8)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? color : .clear)
                            .stroke(isSelected ? Color.clear : color, lineWidth: 3)
                    )
                    .padding(.vertical)
                }
            }
            .padding(.leading)
        }
    }
}


#Preview {
    
    return NavigationStack {
        StatisticsView()
            .environmentObject(
                HabitController(
                    blockHabitRepository: CoreDataBlockHabitStore.preview(),
                    selectedDay: Date().noon!
                )
            )
    }
}
