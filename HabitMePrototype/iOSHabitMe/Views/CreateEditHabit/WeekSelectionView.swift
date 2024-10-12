//
//  WeekSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/11/24.
//

import SwiftUI

struct WeekSelectionView: View {
    
    @Binding var items: [SelectableScheduleDay]
    @State private var isAllSelected: Bool
    
    init(items: Binding<[SelectableScheduleDay]>) {
        
        self._items = items
        self._isAllSelected = State(initialValue: items.contains(where: { $0.wrappedValue.isSelected == false }))
    }
    
    var body: some View {
        
        Grid {
            GridRow {
                ForEach(0..<items.count, id: \.self) { i in
                    
                    let item = items[i]
                    let isSelected = item.isSelected
                    let name = item.name
                    let color = item.color
                    
                    Button {
                        print("tapped selectableHabit")
                        withAnimation {
                            items[i].isSelected.toggle()
                            // We want to make sure that the "All" button is going to be unselected if even one is false
                            if !items[i].isSelected && isAllSelected {
                                isAllSelected = false
                            } else if items[i].isSelected && isAllSelected == false && items.allSatisfy({ $0.isSelected }) {
                                isAllSelected = true
                            }
                        }
                    } label: {
                        Text("\(name)")
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.plain)
                    .filterButtonStyle(color: color, isSelected: isSelected)
                    .gridCellColumns(1)
                }
                

            }
            .frame(maxWidth: .infinity)
        }
    }
}


import HabitRepositoryFW

#Preview {
    @Previewable @State var items: [SelectableScheduleDay] = ScheduleDay.allCases.map { SelectableScheduleDay(scheduleDay: $0, isSelected: true) }
    return WeekSelectionView(items: $items)
}
