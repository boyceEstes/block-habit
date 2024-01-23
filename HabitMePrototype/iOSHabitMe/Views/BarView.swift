//
//  BarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


struct HabitRecordDayView: View {
    
    let graphHeight: CGFloat
    
    var habitRecords: [DataHabitRecord]
    
    var body: some View {
        
        List(habitRecords, id: \.self) { habitRecord in
            Text("\(habitRecord.habit.name)")
        }
        .frame(height: graphHeight)
    }
}

struct BarView: View {
    
    @Environment(\.modelContext) var modelContext
    
    let graphHeight: CGFloat
    
    let dataHabitRecordsOnDate: [DataHabitRecordsOnDate]
    @Binding var selectedDay: Date

    
    var body: some View {
        
        let columnWidth = graphHeight / 5
        
        ScrollViewReader { value in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(0..<dataHabitRecordsOnDate.count, id: \.self) { i in
                        dateColumn(graphHeight: graphHeight, info: dataHabitRecordsOnDate[i])
                            .frame(width: columnWidth, height: graphHeight, alignment: .bottom)
                            .id(dataHabitRecordsOnDate[i].funDate)
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
    func dateColumn(graphHeight: Double, info: DataHabitRecordsOnDate) -> some View {
        
        let habitCount = info.habits.count
        let labelHeight: CGFloat = 30
        // This will also be the usual height
        let itemWidth = (graphHeight - labelHeight) / 8
        let itemHeight = habitCount > 8 ? ((graphHeight - labelHeight) / Double(habitCount)) : itemWidth
        
        VStack(spacing: 0) {
            ForEach(info.habits, id: \.self) { j in
                Rectangle()
                    .fill(Color(hex: j.habit.color) ?? .gray)
                    .frame(width: itemWidth, height: itemHeight)
                    .onTapGesture {
                        setSelectedDay(to: info.funDate)
                    }
            }
            
            
            Rectangle()
                .fill(.ultraThickMaterial)
                .frame(height: 1)
            
            Text("\(info.displayDate)")
                .fontWeight(info.funDate == selectedDay ? .bold : .regular)
                .frame(maxWidth: .infinity, maxHeight: labelHeight)
                .onTapGesture {
                    setSelectedDay(to: info.funDate)
                }
        }
        .contextMenu {
            if habitCount > 0 {
                Button("Delete Last Habit Record") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                        deleteLastHabitRecord(in: info.habits)
                    }
                }
            }
        }
    }
    
    
    private func deleteLastHabitRecord(in habitRecords: [DataHabitRecord]) {
        
        // They are in reverse order so they will need to have the first (not the last) to fetch the
        // most recent habit record
        guard let lastHabitRecord = habitRecords.first else { return }
        
        modelContext.delete(lastHabitRecord)
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
