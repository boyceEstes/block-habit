//
//  BarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


struct HabitRecordDayView: View {
    
    let graphHeight: CGFloat
    
    @Binding var habitRecords: [HabitRecord]
    
    var body: some View {
        
        List($habitRecords, id: \.self) { habitRecord in
            Text("\(habitRecord.wrappedValue.habit.name)")
        }
        .frame(height: graphHeight)
    }
}

//extension Notification.Name {
//    
//    static let resetBarGraphPosition = Notification.Name("reset.bar.graph.position")
//}

struct BarView: View {
    
//    let resetBarGraphPosition = NotificationCenter.default.publisher(for: .resetBarGraphPosition)
    
    let habitRepository: HabitRepository
    let graphHeight: CGFloat
    
    @Binding var habitsOnDates: [HabitsOnDate]
    @Binding var selectedDay: Date

    
    var body: some View {
        
        let columnWidth = graphHeight / 5
        
        ScrollViewReader { value in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(0..<habitsOnDates.count, id: \.self) { i in
                        dateColumn(graphHeight: graphHeight, info: habitsOnDates[i])
                            .frame(width: columnWidth, height: graphHeight, alignment: .bottom)
                            .id(habitsOnDates[i].funDate)
                    }
                }
                .frame(height: graphHeight)
            }
            .onChange(of: habitsOnDates) { oldValue, newValue in
                scrollToSelectedDay(value: value)
            }
//            .onReceive(resetBarGraphPosition) { output in
//                scrollToSelectedDay(value: value)
//            }
        }
    }
    
    
    @ViewBuilder
    func dateColumn(graphHeight: Double, info: HabitsOnDate) -> some View {
        
        let habitCount = info.habits.count
        let labelHeight: CGFloat = 30
        // This will also be the usual height
        let itemWidth = (graphHeight - labelHeight) / 8
        let itemHeight = habitCount > 8 ? ((graphHeight - labelHeight) / Double(habitCount)) : itemWidth
        
        VStack(spacing: 0) {
            ForEach(info.habits, id: \.self) { j in
                Rectangle()
                    .fill(j.habit.color)
                    .frame(width: itemWidth, height: itemHeight)
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
    }
    
    
    private func setSelectedDay(to date: Date) {
        
        guard let dateNoon = date.noon else { return }
        selectedDay = dateNoon
    }
    
    
    private func scrollToSelectedDay(value: ScrollViewProxy) {
        
        DispatchQueue.main.async {
            // get days since january and then count back to get their ids, or I could
            // set the id as a date
            
            value.scrollTo(selectedDay, anchor: .center)
//                    value.scrollTo(habitsOnDates.count - 1, anchor: .trailing)
        }
    }
}
