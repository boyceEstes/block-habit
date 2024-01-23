//
//  HabitsMenu.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


struct HabitsMenu: View {
    
    // TODO: load habits from db
    let habits: [DataHabit]
    
    let habitMenuHeight: CGFloat
    let didTapCreateHabitButton: () -> Void
    let didTapHabitButton: (DataHabit) -> Void
    
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                Text("Habits")
                    .font(.title2)
                Spacer()
                Button {
                    didTapCreateHabitButton()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.vertical, 30)
            
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(0..<habits.count, id: \.self) { i in
                        
                        let habit = habits[i]
                        habitButton(habit: habit)
                    }
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
//            .frame(height: habitMenuHeight)
//            .background(Color.indigo)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 20))
        .padding()
    }
    
    
    func habitButton(habit: DataHabit) -> some View {
        
        Button {
            didTapHabitButton(habit)
        } label: {
            Text("\(habit.name)")
                .fontWeight(.semibold)
                .font(.system(size: 17))
                .frame(width: 150, height: 50)
                .background(Color(hex: habit.color))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
