//
//  HScrollBarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/8/24.
//

import SwiftUI
import HabitRepositoryFW

//struct HScrollBarView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}


struct HScrollBarView: View {
    
    // MARK: Environment
    @EnvironmentObject var habitController: HabitController
    // MARK: Injected Properties
    let graphWidth: CGFloat
    let graphHeight: CGFloat
    let numOfItemsToReachTop: Double
    let habitRecordsForDays: [Date: [HabitRecord]]
    @Binding var selectedDay: Date
    let animation: Namespace.ID
    let destroyHabitRecord: (HabitRecord) -> Void
    
    
    
    var body: some View {
        
        // TODO: If the device is horizontal, do not use this calculation
        let columnWidth = graphWidth / 5
        VStack {
            
            ScrollViewReader { value in
                
                ScrollView(.horizontal) {
                    
                    LazyHStack(spacing: 0) {
                        
                        ForEach(habitRecordsForDays.sorted(by: { $0.key < $1.key}), id: \.key) { date, habitRecords in
                            dateColumn(
                                graphHeight: graphHeight,
                                numOfItemsToReachTop: numOfItemsToReachTop,
                                date: date,
                                habitRecords: habitRecords
                            )
                            .frame(width: columnWidth, height: graphHeight, alignment: .bottom)
                            .id(date)
                        }
                    }
                    .frame(height: graphHeight)
                }
                .onChange(of: habitRecordsForDays, { oldValue, newValue in
                    
                    scrollToSelectedDay(value: value, animate: false)
                })
                .onChange(of: selectedDay) { oldValue, newValue in
                    scrollToSelectedDay(value: value)
                }
                .onAppear {
                    scrollToSelectedDay(value: value, animate: false)
                }
            }
        }
    }
    
    
    @ViewBuilder
    func dateColumn(
        graphHeight: Double,
        numOfItemsToReachTop: Double,
        date: Date,
        habitRecords: [HabitRecord]
    ) -> some View {
        
        let habitCount = habitRecords.count
        let labelHeight: CGFloat = 30
        // This will also be the usual height
        let itemWidth = (graphHeight - labelHeight) / numOfItemsToReachTop
        let itemHeight = habitCount > Int(numOfItemsToReachTop) ? ((graphHeight - labelHeight) / Double(habitCount)) : itemWidth
        
        VStack(spacing: 0) {

            BlockStack(
                habitRecords: habitRecords,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                animation: animation,
                didTapBlock: {
                    print("tapped dat ish")
                    habitController.setSelectedDay(to: date)
                }
            )
            
            Rectangle()
                .fill(.ultraThickMaterial)
                .frame(height: 1)
            
            Text("\(date.displayDate)")
                .font(.footnote)
                .fontWeight(date == selectedDay ? .bold : .regular)
                .frame(maxWidth: .infinity, maxHeight: labelHeight)
                .onTapGesture {
                    // MARK: TO CHANGE OR NOT TO CHANGE
                    print("tapped on display date")
                    habitController.setSelectedDay(to: date)
                }
        }
        .contextMenu {
            if habitCount > 0 {
                Button("Delete Last Habit Record") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                        deleteLastHabitRecord(in: habitRecords)
                    }
                }
            }
        }
    }
    
    
    private func deleteLastHabitRecord(in habitRecords: [HabitRecord]) {
        
        // They are in reverse order so they will need to have the first (not the last) to fetch the
        // most recent habit record
        guard let lastHabitRecord = habitRecords.first else { return }
        
        destroyHabitRecord(lastHabitRecord)
    }
    
    
    private func setSelectedDay(to date: Date) {
        
        guard let dateNoon = date.noon else { return }
        selectedDay = dateNoon
    }
    
    
    private func scrollToSelectedDay(value: ScrollViewProxy, animate: Bool = true) {
        
        print("Hi I have appeared and now I am meant to be scrolling to the selected Day '\(DateFormatter.shortDate.string(from: selectedDay))'")
        DispatchQueue.main.async {
            // get days since january and then count back to get their ids, or I could
            // set the id as a date
            if animate {
                withAnimation(.easeInOut) {
                    value.scrollTo(selectedDay, anchor: .center)
                }
            } else {
                value.scrollTo(selectedDay, anchor: .center)
            }
        }
    }
}


#Preview {
    
    let maxNumOfItemsBeforeCrushing = 10.0
    @State var day = Date()
    @Namespace var namespace

    
    return HScrollBarView(
        graphWidth: 300,
        graphHeight: 300,
        numOfItemsToReachTop: maxNumOfItemsBeforeCrushing,
        habitRecordsForDays: HabitRecord.recordsForDaysPreview(date: day),
        selectedDay: $day,
        animation: namespace,
        destroyHabitRecord: { _ in }
    )
}
