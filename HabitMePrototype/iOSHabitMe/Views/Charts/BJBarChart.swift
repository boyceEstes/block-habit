//
//  BarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import HabitRepositoryFW


struct StatisticsBarView: View {
    
    let graphWidth: CGFloat
    let graphHeight: CGFloat
    let numOfItemsToReachTop: Double
    
    let datesWithHabitRecords: [Date: [HabitRecord]]
    
    var body: some View {
        
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .bottom, spacing: 0) {
                    ForEach(datesWithHabitRecords.sorted(by: { $0.key < $1.key}), id: \.key) { date, habitRecords in
                        dateColumn(
                            graphHeight: graphHeight,
                            numOfItemsToReachTop: numOfItemsToReachTop,
                            date: date,
                            habitRecords: habitRecords
                        )
                        .id(date)
                    }
                }
                .frame(height: graphHeight, alignment: .trailing)
            }
            .onAppear {
                scrollToToday(value: value)
            }
        }
    }
    
    /// This will build a column without a selectable day
    @ViewBuilder
    func dateColumn(
        graphHeight: Double,
        numOfItemsToReachTop: Double,
        date: Date,
        habitRecords: [HabitRecord]
    ) -> some View {
        
        let habitCount = habitRecords.count
        let itemWidth = (graphHeight) / numOfItemsToReachTop
        let itemHeight = habitCount > Int(numOfItemsToReachTop) ? ((graphHeight) / Double(habitCount)) : itemWidth
        
        VStack(spacing: 0) {
            
            if habitRecords.isEmpty {
//                ActivityBlock(colorHex: UIColor.secondarySystemGroupedBackground.toHexString() ?? "#FFFFFF", itemWidth: itemWidth, itemHeight: itemHeight)
                Rectangle()
                    .frame(width: itemWidth, height: itemHeight).opacity(0)
            } else {
                HabitRecordBlocksOnDate(habitRecords: habitRecords, itemWidth: itemWidth, itemHeight: itemHeight, didTapBlock: { })
                    .padding(.horizontal, 1)
            }
            
            Rectangle()
                .fill(.ultraThickMaterial)
                .frame(height: 1)
            
            // This isn't very useful because it is too crunched to really be seen, need to think of a better way to group things.
//            Text("\(date.displayDate)")
//                .fontWeight(.regular)
        }
    }
    
    
    private func scrollToToday(value: ScrollViewProxy, animate: Bool = true) {
        
        DispatchQueue.main.async {
            guard let today = Date().noon else { return }
            // get days since january and then count back to get their ids, or I could
            // set the id as a date
            if animate {
                withAnimation(.easeInOut) {
                    value.scrollTo(today, anchor: .trailing)
                }
            } else {
                value.scrollTo(today, anchor: .trailing)
            }
        }
    }
}


struct BarView: View {
    
    @Environment(\.modelContext) var modelContext
    
    let graphWidth: CGFloat
    let graphHeight: CGFloat
    let numOfItemsToReachTop: Double
    
    
    let datesWithHabitRecords: [Date: [HabitRecord]]
    @Binding var selectedDay: Date
    let destroyHabitRecord: (HabitRecord) -> Void
    
    var body: some View {
        
        // TODO: If the device is horizontal, do not use this calculation
        let columnWidth = graphWidth / 5
        
        ScrollViewReader { value in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(datesWithHabitRecords.sorted(by: { $0.key < $1.key}), id: \.key) { date, activityRecords in
                        dateColumn(
                            graphHeight: graphHeight,
                            numOfItemsToReachTop: numOfItemsToReachTop,
                            date: date,
                            activityRecords: activityRecords
                        )
                            .frame(width: columnWidth, height: graphHeight, alignment: .bottom)
                            .id(date)
                    }
                }
                .frame(height: graphHeight)
            }
            .onChange(of: selectedDay) { oldValue, newValue in
                scrollToSelectedDay(value: value)
            }
            .onAppear {
                scrollToSelectedDay(value: value, animate: false)
            }
        }
    }
    
    
    @ViewBuilder
    func dateColumn(
        graphHeight: Double,
        numOfItemsToReachTop: Double,
        date: Date,
        activityRecords: [HabitRecord]
    ) -> some View {
        
        let habitCount = activityRecords.count
        let labelHeight: CGFloat = 30
        // This will also be the usual height
        let itemWidth = (graphHeight - labelHeight) / numOfItemsToReachTop
        let itemHeight = habitCount > Int(numOfItemsToReachTop) ? ((graphHeight - labelHeight) / Double(habitCount)) : itemWidth
        
        VStack(spacing: 0) {

            HabitRecordBlocksOnDate(
                habitRecords: activityRecords,
                itemWidth: itemWidth,
                itemHeight: itemHeight
            ) {
                setSelectedDay(to: date)
            }
            
            Rectangle()
                .fill(.ultraThickMaterial)
                .frame(height: 1)
            
            Text("\(date.displayDate)")
                .font(.footnote)
                .fontWeight(date == selectedDay ? .bold : .regular)
                .frame(maxWidth: .infinity, maxHeight: labelHeight)
                .onTapGesture {
                    setSelectedDay(to: date)
                }
        }
        .contextMenu {
            if habitCount > 0 {
                Button("Delete Last Habit Record") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                        deleteLastHabitRecord(in: activityRecords)
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


struct HabitRecordBlocksOnDate: View {
    
    let habitRecords: [HabitRecord]
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let didTapBlock: () -> Void
    
    var body: some View {
        ForEach(habitRecords, id: \.self) { habitRecord in
            
            let _ = print("-- completionDate: \(habitRecord.completionDate)")
            let _ = print("-- creationDate: \(habitRecord.creationDate)")
            
            let isLastRecord = habitRecords.first == habitRecord
            
            ActivityBlock(
                colorHex: habitRecord.habit.color,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                tapAction: didTapBlock
            )
            .clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: isLastRecord ? .bigBlockCornerRadius : 0,
                        topTrailing: isLastRecord ? .bigBlockCornerRadius : 0
                    )
                )
            )
        }
    }
}


struct ActivityBlock: View {
    
    let colorHex: String
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let tapAction: () -> Void
    
    init(colorHex: String, itemWidth: CGFloat, itemHeight: CGFloat, tapAction: @escaping () -> Void = {}) {
        self.colorHex = colorHex
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.tapAction = tapAction
    }
    
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    
    var body: some View {
        
        Rectangle()
            .fill(color)
            .frame(width: itemWidth, height: itemHeight)
            .onTapGesture(perform: tapAction)
    }
}
