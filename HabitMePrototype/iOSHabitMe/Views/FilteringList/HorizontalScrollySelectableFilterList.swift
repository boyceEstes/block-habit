//
//  HorizontalScrollySelectableFilterList.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import SwiftUI

struct HorizontalScrollySelectableFilterList<T: SelectableListItem>: View {
    
    @Binding var items: [T]
    @State private var isAllSelected = true
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                Button {
                    withAnimation {
                        if isAllSelected {
                            // Set none to be selected
                            isAllSelected = false
                            items.indices.forEach { items[$0].isSelected = false }
                            
                        } else {
                            // Set all to be selected
                            isAllSelected = true
                            items.indices.forEach { items[$0].isSelected = true }
                        }
                    }
                } label: {
                    Text("All")
                        .foregroundStyle(.white)
                }
                .filterButtonStyle(color: .blue, isSelected: isAllSelected)
                
                Divider()
                
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
                    .filterButtonStyle(color: color, isSelected: isSelected)
                }
            }
            .padding(.leading)
            .padding(.vertical)
        }
    }
}


#if DEBUG
import HabitRepositoryFW

#Preview {
    
    @Previewable @State var items: [SelectableHabit] = Habit.previewHabits.map { SelectableHabit(habit: $0) }
    return HorizontalScrollySelectableFilterList(items: $items)
}

#endif
