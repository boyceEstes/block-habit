//
//  StatisticsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/27/24.
//

import SwiftUI
import SwiftData

/*
 * To keep things as simple as I can think, I would want to keep this on the Home Screen and use
 * the existing Bar view on that screen. Interact with that bar view by tapping on filters which
 * would update the stats that will be displayed in this view.
 */

struct SelectableHabit: Hashable {
    
    let habit: DataHabit
    var isSelected: Bool = true
}

struct StatisticsView: View {
    
//    let selectableHabits: [SelectableHabit]
    @State private var isFiltering = true
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Statistics")
                
                Spacer()
                
                Button {
                    withAnimation {
                        isFiltering.toggle()
                    }
                } label: {
                    if !isFiltering {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .homeDetailTitle()
            
            ScrollView {
                if isFiltering {
                    VStack(alignment: .leading) {
                        LazyHStack {
                            //                        ForEach(selectableHabits, id: \.self) { selectableHabit in
                            //                            Button {
                            //                                print("tapped selectableHabit")
                            //                                selectableHabit.isSelected.toggle()
                            //                            } label: {
                            //                                Text(selectableHabit.habit.name)
                            //                            }
                            //                        }
                        }
                        Button("Reset") {
                            print("Tapped Reset")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                }
                
                Grid(alignment: .topLeading) {
                    
                    GridRow {
                        StatBox(title: "Total Records", value: "150")
                        StatBox(title: "Average Records / Day", value: "9.2", units: "rpd")
                    }
                    GridRow {
                        StatBox(title: "Most Completions", value: "42", units: "records", subValue: "Journaling")
                        StatBox(title: "Best Streak", value: "10", units: "days", subValue: "Meditation")
                    }
                }
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
//    
//    private func filterButton(habit: DataHabit) -> some View {
//        
//        Button {
//            
//        } label: {
//            
//        }
//    }
}



#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    let dataHabit = DataHabit(
        id: UUID().uuidString,
        name: "Chugged Dew",
        color: Habit.habits[0].color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    let dataHabit2 = DataHabit(
        id: UUID().uuidString,
        name: "Smashed Taco",
        color: Habit.habits[1].color.toHexString() ?? "#FFFFFF",
        habitRecords: []
    )
    container.mainContext.insert(dataHabit)
    container.mainContext.insert(dataHabit2)
    
//    let dataHabitRecord = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: -1),
//        habit: dataHabit
//    )
//    let dataHabitRecord2 = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: -2),
//        habit: dataHabit
//    )
//    let dataHabitRecord3 = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: -2),
//        habit: dataHabit
//    )
//    
//    container.mainContext.insert(dataHabitRecord)
//    container.mainContext.insert(dataHabitRecord2)
//    container.mainContext.insert(dataHabitRecord3)
//    
//    
//    let dataHabitRecord21 = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: 0),
//        habit: dataHabit2
//    )
//    let dataHabitRecord22 = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: -1),
//        habit: dataHabit2
//    )
//    let dataHabitRecord23 = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: -1),
//        habit: dataHabit2
//    )
//    let dataHabitRecord24 = DataHabitRecord(
//        creationDate: Date(),
//        completionDate: Date().adding(days: -2),
//        habit: dataHabit2
//    )
//    
//    container.mainContext.insert(dataHabitRecord21)
//    container.mainContext.insert(dataHabitRecord22)
//    container.mainContext.insert(dataHabitRecord23)
//    container.mainContext.insert(dataHabitRecord24)
//    
//    
//    
    
    return StatisticsView()
}
