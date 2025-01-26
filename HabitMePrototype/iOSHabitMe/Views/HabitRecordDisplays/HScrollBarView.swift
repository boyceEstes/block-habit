//
//  HScrollBarView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/8/24.
//

import SwiftUI
import HabitRepositoryFW


struct HScrollBarView: View {
    
    // MARK: Environment
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var habitController: HabitController
    // MARK: Injected Properties
    let graphWidth: CGFloat
    let graphHeight: CGFloat
    let numOfItemsToReachTop: Double
    let habitRecordsForDays: [Date: [HabitRecord]]
    @Binding var selectedDay: Date
    let animation: Namespace.ID
    @Binding var showDayDetail: Bool
    
    /// Fitting less dates on the screen means that there is more room for bigger fonts
    var numOfDatesToFitOnGraph: CGFloat {
        
        if dynamicTypeSize < .xxxLarge {
            return 5.0
        } else if dynamicTypeSize < .accessibility1 {
            return 4.0
        } else if dynamicTypeSize < .accessibility4 {
            return 4.0
        } else {
            return 3.0
        }
    }
    
    var body: some View {
        
        // TODO: If the device is horizontal, do not use this calculation

        let columnWidth = graphWidth / numOfDatesToFitOnGraph
        
        VStack {
            
            ScrollViewReader { value in
                
                ScrollView(.horizontal) {
                    
                    LazyHStack(spacing: 0) {
                        
                        ForEach(habitRecordsForDays.sorted(by: { $0.key < $1.key}), id: \.key) { date, habitRecords in
                            
                            DateColumn(
                                graphHeight: graphHeight,
                                numOfItemsToReachTop: numOfItemsToReachTop,
                                date: date, // For column
                                habitRecords: habitRecords,
                                selectedDay: selectedDay
                            ) {
                                if Calendar.current.isDate(date, inSameDayAs: selectedDay) {
                                    showDayDetail = true
                                } else {
                                    habitController.setSelectedDay(to: date)
                                }
                            }
                            .frame(width: columnWidth)
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
    
    
//    @ViewBuilder
//    func dateColumn(
//        graphHeight: Double,
//        numOfItemsToReachTop: Double,
//        date: Date,
//        habitRecords: [HabitRecord]
//    ) -> some View {
//        
//        let habitCount = habitRecords.count
////        let labelHeight: CGFloat = 30
//        @ScaledMetric(relativeTo: .body) var labelHeight: CGFloat = 30
//        let dividerHeight: CGFloat = 1
//        // This will also be the usual height
//        var barAreaHeight: CGFloat {
//            graphHeight - labelHeight - dividerHeight
//        }
//        var itemWidth: CGFloat {
//            barAreaHeight / numOfItemsToReachTop
//        }
//        
//        // If there are 4 items to reach the top...
//        // Your graph is 100
//        // your label takes up 30
//        // your available space would then be 70
//        // We would then want to say that each block would be 70 / 10, its smaller
//        // Otherwise if we are <= habitCount then we would just divide it by the number to reach the top (4)
//        
//        let itemHeight = habitCount > Int(numOfItemsToReachTop) ? (barAreaHeight / Double(habitCount)) : itemWidth
//        
//
//        VStack(spacing: 0) {
//            
//            BlockStack(
//                habitRecords: habitRecords,
//                itemWidth: itemWidth,
//                itemHeight: itemHeight,
//                didTapBlock: {
//                    if Calendar.current.isDate(date, inSameDayAs: selectedDay) {
//                        showDayDetail = true
//                    } else {
//                        habitController.setSelectedDay(to: date)
//                    }
//                }
//            )
//            
//            Rectangle()
//                .fill(.ultraThickMaterial)
//                .frame(height: dividerHeight)
//            
//            Text("\(date.displayDate(dynamicTypeSize))")
//                .font(.footnote)
//                .fontWeight(date == selectedDay ? .bold : .regular)
//                .frame(maxWidth: .infinity, maxHeight: labelHeight)
//                .onTapGesture {
//                    // MARK: TO CHANGE OR NOT TO CHANGE
//                    print("tapped on display date")
//                    habitController.setSelectedDay(to: date)
//                }
//        }
//        .frame(maxHeight: .infinity, alignment: .bottom)
//    }
    
    
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


struct DateColumn: View {
    
    // Environment
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    // Injected
    let graphHeight: Double
    let numOfItemsToReachTop: Double
    let date: Date
    let habitRecords: [HabitRecord]
    let selectedDay: Date
    let tapAction: () -> Void
    // Constants
    let dividerHeight: CGFloat = 1
    // View Properties
    @ScaledMetric(relativeTo: .body) var labelHeight: CGFloat = 30
    
    // Computed
    var habitCount: CGFloat {
        CGFloat(habitRecords.count)
    }
    var barAreaHeight: CGFloat {
        graphHeight - labelHeight - dividerHeight
    }
    var itemWidth: CGFloat {
        barAreaHeight / numOfItemsToReachTop
    }
    var itemHeight: CGFloat {
        CGFloat(habitCount > CGFloat(numOfItemsToReachTop) ? (barAreaHeight / CGFloat(habitCount)) : itemWidth)
    }
    
    
    var body: some View {

        
        // If there are 4 items to reach the top...
        // Your graph is 100
        // your label takes up 30
        // your available space would then be 70
        // We would then want to say that each block would be 70 / 10, its smaller
        // Otherwise if we are <= habitCount then we would just divide it by the number to reach the top (4)
        


        VStack(spacing: 0) {
            
            BlockStack(
                habitRecords: habitRecords,
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                didTapBlock: tapAction
            )
            
            Rectangle()
                .fill(.ultraThickMaterial)
                .frame(height: dividerHeight)
            
            Text("\(date.displayDate(dynamicTypeSize))")
                .font(.footnote)
                .fontWeight(date == selectedDay ? .bold : .regular)
                .frame(maxWidth: .infinity, maxHeight: labelHeight)
                .onTapGesture {
                    // MARK: TO CHANGE OR NOT TO CHANGE
                    print("tapped on display date")
                    tapAction()
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}


#Preview {

    @Previewable @Namespace var namespace
    @Previewable @State var showDayDetail = false
    @Previewable @State var day = Date()

    let maxNumOfItemsBeforeCrushing = 4.0
    
    VStack {
        Text("Top")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
        
        HScrollBarView(
            graphWidth: 300,
            graphHeight: 200,
            numOfItemsToReachTop: maxNumOfItemsBeforeCrushing,
            habitRecordsForDays: HabitRecord.recordsForDaysPreview(date: Date()),
            selectedDay: $day,
            animation: namespace,
            showDayDetail: $showDayDetail
        )
        
        Text("Bottom")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.yellow)
    }
}
