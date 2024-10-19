//
//  ArchivedHabitsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/19/24.
//

import SwiftUI
import HabitRepositoryFW


struct ArchivedHabitsView: View {
    
    @EnvironmentObject var habitController: HabitController
    
    var archivedHabits: [Habit] {
        habitController.latestArchivedHabits
    }
    
    var body: some View {
        
        Group {
            if !archivedHabits.isEmpty {
                List {
                    ForEach(archivedHabits, id: \.id) { archivedHabit in
                        
                        ArchivedItemRow(name: archivedHabit.name) {
                            habitController.deleteHabit(archivedHabit)
                        } restoreItem: {
                            habitController.restoreHabit(archivedHabit)
                        }
                        .swipeActions(edge: .leading) {
                            // Restore
                            Button {
                                habitController.restoreHabit(archivedHabit)
                            } label: {
                                Label {
                                    Text("Restore")
                                } icon: {
                                    BJAsset.restore.image()
                                }
                            }
                            .tint(Color.restore)
                        }
                        .swipeActions(edge: .trailing) {
                            // Delete
                            Button(role: .destructive) {
                                habitController.deleteHabit(archivedHabit)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } else {
                
                VStack {
                    Image(systemName: "archivebox")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                    
                    Text("No Archived Habits")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    
                    Text("Come back after you've archived a habit")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Archived Habits")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    NavigationStack {
        ArchivedHabitsView()
            .environmentObject(
                HabitController(
                    blockHabitRepository: CoreDataBlockHabitStore.preview(),
                    selectedDay: Date()
                )
            )
    }
}
