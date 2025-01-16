//
//  DayView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/24/24.
//

import SwiftUI
import HabitRepositoryFW

struct DayDetailView: View {
    
    
    let destroyHabitRecord: (HabitRecord) -> Void
    let goToHabitRecordDetail: (HabitRecord) -> Void
    /// We want this to determine the itemHeight, alternatively we could just set the item height/width
    let graphHeight: CGFloat
    // We want this to keep the same itemHeight/width when presenting the squares in the list
    let numOfItemsToReachTop: Int
    
    // This should be the same as in `dateColumn(graph:numOfItemsToReachTop:info)`
    let dateLabelHeight: CGFloat = 30
    var itemWidth: CGFloat { (graphHeight - dateLabelHeight) / CGFloat(numOfItemsToReachTop) }
    var itemHeight: CGFloat { itemWidth }
    
    var habitRecords: [HabitRecord]
    let selectedDay: Date
    let animation: Namespace.ID
    @Binding var showDayDetail: Bool
    
    
    
    init(
        destroyHabitRecord: @escaping (HabitRecord) -> Void,
        goToHabitRecordDetail: @escaping (HabitRecord) -> Void,
        graphHeight: CGFloat,
        numOfItemsToReachTop: Int,
        habitRecords: [HabitRecord],
        selectedDay: Date,
        animation: Namespace.ID,
        showDayDetail: Binding<Bool>
    ) {
        self.destroyHabitRecord = destroyHabitRecord
        self.goToHabitRecordDetail = goToHabitRecordDetail
        self.graphHeight = graphHeight
        self.numOfItemsToReachTop = numOfItemsToReachTop
        self.habitRecords = habitRecords
        self.selectedDay = selectedDay
        self.animation = animation
        self._showDayDetail = showDayDetail
    }
    
    
    var body: some View {
        
        List {
            Section {
                ForEach(habitRecords, id: \.self) { habitRecord in
                    
                    HStack(spacing: 16) {
                        
                        ActivityBlock(
                            color: Color(hex: habitRecord.habit.color) ?? Color.black,
                            itemWidth: 32,
                            itemHeight: 32
                        )
                        .matchedGeometryEffect(
                            id: habitRecord.id,
                            in: animation,
                            anchor: .center,
                            isSource: true
                        )
                        
                        ActivityRecordRowTitleDate(
                            selectedDay: selectedDay,
                            activityRecord: habitRecord
                        )
                        .sectionBackground(
                            padding: .detailPadding,
                            color: .secondaryBackground
                        )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            destroyHabitRecord(habitRecord)
                            print("Deleting!")
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundStyle(Color.blue)
                        }
                    }
                    .onTapGesture {
                        // FIXME: This is broken Cannot navigate to habit record detail without a DataHabitRecord right now
                        goToHabitRecordDetail(habitRecord)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.primaryBackground)
            } header: {
                HStack {
                    Text("Day Records")
                    Spacer()
                    Button {
                        withAnimation {
                            showDayDetail = false
                        }
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                }
            }
        }
        .frame(maxHeight: graphHeight)
//        .background(Color(uiColor: .systemGroupedBackground))
//        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}


#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var showDayDetail = false
    
    return DayDetailView(
        destroyHabitRecord: { _ in },
        goToHabitRecordDetail: { _ in },
        graphHeight: 300,
        numOfItemsToReachTop: 10,
        habitRecords: HabitRecord.previewRecords,
        selectedDay: Date(),
        animation: namespace,
        showDayDetail: $showDayDetail
    )
    
    
//    DayDetailView(
//        graphHeight: 300,
//        habitRecords: [
//            DataHabitRecord(creationDate: Date(), completionDate: Date(), habit: DataHabit(name: "Any", color: "#FFFFFF", habitRecords: []))
//        ]
//    )
}
