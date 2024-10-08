//
//  BarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI
import HabitRepositoryFW


struct StatisticsBarView: View {
    
    @Namespace private var animation
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
                
                BlockStack(
                    habitRecords: habitRecords,
                    itemWidth: itemWidth,
                    itemHeight: itemHeight,
                    animation: animation,
                    didTapBlock: { }
                )
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

