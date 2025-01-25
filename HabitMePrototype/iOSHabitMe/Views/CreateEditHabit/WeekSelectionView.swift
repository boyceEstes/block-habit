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
                    
                    ToggleButton(
                        title: item.name,
                        isOn: isSelected,
                        color: item.color
                    ) {
                        withAnimation {
                            items[i].isSelected.toggle()
                            // We want to make sure that the "All" button is going to be unselected if even one is false
                            if !items[i].isSelected && isAllSelected {
                                isAllSelected = false
                            } else if items[i].isSelected && isAllSelected == false && items.allSatisfy({ $0.isSelected }) {
                                isAllSelected = true
                            }
                        }
                    }
                    .gridCellColumns(1)
//                    Button {
//                        print("tapped selectableHabit")
//                        withAnimation {
//                            items[i].isSelected.toggle()
//                            // We want to make sure that the "All" button is going to be unselected if even one is false
//                            if !items[i].isSelected && isAllSelected {
//                                isAllSelected = false
//                            } else if items[i].isSelected && isAllSelected == false && items.allSatisfy({ $0.isSelected }) {
//                                isAllSelected = true
//                            }
//                        }
//                    } label: {
//                        Text("\(name)")
//                            .foregroundStyle(isSelected ? Color.white : .primary)
//                    }
                    
//                    .buttonStyle(.plain)
                    
//                    .gridCellColumns(1)
                }
                

            }
            .frame(maxWidth: .infinity)
        }
    }
}


struct ToggleButton: View {
    
    let title: String
    let isOn: Bool
    let color: Color
    let tapAction: () -> Void
    
    var body: some View {
        
        Button {
            tapAction()
        } label: {
            Text("\(title)")
                .foregroundStyle(isOn ? Color.white : .primary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .filterButtonStyle(color: color, isSelected: isOn)
    }
}


import HabitRepositoryFW

#Preview {
    @Previewable @State var items: [SelectableScheduleDay] = ScheduleDay.allCases.map { SelectableScheduleDay(scheduleDay: $0, isSelected: true) }
    return WeekSelectionView(items: $items)
}
