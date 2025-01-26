//
//  WeekSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/11/24.
//

import SwiftUI

struct WeekSelectionView: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Binding var items: [SelectableScheduleDay]
    @State private var isAllSelected: Bool
    
    init(items: Binding<[SelectableScheduleDay]>) {
        
        self._items = items
        self._isAllSelected = State(initialValue: items.contains(where: { $0.wrappedValue.isSelected == false }))
    }
    
    var body: some View {
        
        if dynamicTypeSize.isAccessibilitySize {
            
            NavigationLink{
                MultiSelectWeekDayPicker(selectedItems: $items, isAllSelected: $isAllSelected)
            } label: {
                Text("Days")
                    .padding(.vertical, 6)
            }
        } else {
            Grid {
                GridRow {
                    ForEach(0..<items.count, id: \.self) { i in
                        
                        let item = items[i]
                        let isSelected = item.isSelected
                        
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
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}


struct MultiSelectWeekDayPicker: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedItems: [SelectableScheduleDay]
    @Binding var isAllSelected: Bool

    var body: some View {
        
            List {
                Section {
                    ForEach(0..<selectedItems.count, id: \.self) { i in
                        HStack {
                            let item = selectedItems[i]
                            let isSelected = item.isSelected
                            
                            
                            Text(item.scheduleDay.fullName)
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .imageScale(.small)
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedItems[i].isSelected.toggle()
                                // We want to make sure that the "All" button is going to be unselected if even one is false
                                if !selectedItems[i].isSelected && isAllSelected {
                                    isAllSelected = false
                                } else if selectedItems[i].isSelected && isAllSelected == false && selectedItems.allSatisfy({ $0.isSelected }) {
                                    isAllSelected = true
                                }
                            }
                        }
                    }
                } footer: {
                    Text("Notifications will be delivered \(selectedItems.scheduleSummary)")
                }
            }
            .navigationTitle("Select Days")
    }
}


extension Array where Element == SelectableScheduleDay {
    
    var scheduleSummary: String {
        
//        switch schedulingUnits {
//        case .daily:
//            if rate == 1 {
//                return "Daily"
//            } else {
//                return "Every \(rate) days"
//            }
//        case .weekly:
        let areAllSelected: Bool = reduce(true) { partial, newDay in
            if partial == false || !newDay.isSelected {
                return false
            } else {
                return true
            }
        }
        
        if areAllSelected {
            return "Daily"
        } else {
            return self.sorted { $0.scheduleDay.rawValue < $1.scheduleDay.rawValue }.compactMap {
                if $0.isSelected {
                    return $0.scheduleDay.abbreviation
                } else {
                    return nil
                }
            }.joined(separator: ", ")
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
