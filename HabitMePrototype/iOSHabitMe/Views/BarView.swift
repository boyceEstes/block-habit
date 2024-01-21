//
//  BarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI

struct BarView: View {
    
    let habitRepository: HabitRepository
    let graphHeight: CGFloat
    
    @Binding var habitsOnDates: [HabitsOnDate]

    
    var body: some View {
        
        let columnWidth = graphHeight / 5
        
        ScrollViewReader { value in
            
            ScrollView(.horizontal) {
                
                LazyHStack(spacing: 0) {
                    
                    ForEach(0..<habitsOnDates.count, id: \.self) { i in
                        dateColumn(graphHeight: graphHeight, info: habitsOnDates[i])
                            .frame(width: columnWidth, height: graphHeight, alignment: .bottom)
                    }
                }
                .frame(height: graphHeight)
            }
            .onChange(of: habitsOnDates) { oldValue, newValue in
                DispatchQueue.main.async {
                    value.scrollTo(habitsOnDates.count - 1, anchor: .trailing)
                }
            }
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
                .frame(maxWidth: .infinity, maxHeight: labelHeight )
//                .background(Color.red)
        }
    }
}
