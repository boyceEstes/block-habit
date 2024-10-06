//
//  SelectableHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//

import SwiftUI
import HabitRepositoryFW

struct SelectableHabitView: View {
    
    // MARK: Injected Properties
    let habit: IsCompletedHabit
    // MARK: View Info
    @ScaledMetric(relativeTo: .body) var detailHeight = 12
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading, spacing: 0) {
                    Text("\(habit.habit.name) longer name and stuff that 's even longer")

                    .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(2, reservesSpace: true)
                
                // injecting height to resize the icons according to the height
                ActivityDetailIndicators(
                    activityDetails: habit.habit.activityDetails,
                    detailHeight: detailHeight
                )
                    .frame(maxHeight: detailHeight)
                }
            .foregroundStyle(.white)
            
            
            Button {
                
            } label: {
                // This depends on a lot.
                Image(systemName: "checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(habit.isCompleted ? Color(hex: habit.habit.color) : Color.black.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.leading)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex:habit.habit.color)!)
        )
//        .background(
//            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                .fill(
//                    .shadow(.inner(color: Color(red: 197/255, green: 197/255, blue: 197/255),radius: 3, x:3, y: 3))
//                    .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
//                )
//                .foregroundColor(Color(red: 236/255, green: 234/255, blue: 235/255)
//                                )
//        )
//                .shadow(color: habit.isCompleted ? .black.opacity(0.8) : .clear, radius: 7, x: 0, y: 8)
//        .background(habit.isCompleted ? Color(hex: habit.habit.color).opacity(0.8) : Color(hex: habit.habit.color).opacity(1))
//        .shadow(color: habit.isCompleted ? .black.opacity(0.8) : .clear, radius: 7, x: 0, y: 8)
//        .clipShape(
//            RoundedRectangle(cornerRadius: 10)
//        )
//        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        
//        .font(.headline)
//        .frame(maxWidth: buttonWidth ?? .infinity)
//        .frame(height: 50)
//        .background(!looksDisabled ? color : color.opacity(0.5))
//        .foregroundStyle(!looksDisabled ? Color.white : Color.white.opacity(0.5))
//        .shadow(color: !looksDisabled ? .clear : .black.opacity(0.6), radius: 20)
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    
    VStack {
        HStack(spacing: 8) {
            SelectableHabitView(
                habit: IsCompletedHabit(
                    habit: .mirrorPepTalk,
                    isCompleted: false
                )
            )
            
            SelectableHabitView(
                habit: IsCompletedHabit(
                    habit: .drinkTheKoolaid,
                    isCompleted: false
                )
            )
        }
        .padding(.horizontal, 8)
        
        SelectableHabitView(
            habit: IsCompletedHabit(
                habit: .somethingComplicated,
                isCompleted: true
            )
        )
    }
}
