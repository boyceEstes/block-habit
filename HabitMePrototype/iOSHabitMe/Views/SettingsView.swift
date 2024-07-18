//
//  SettingsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 5/14/24.
//

import SwiftUI
import HabitRepositoryFW
import TipKit


struct ArchiveTip: Tip {
    
    var title: Text {
        Text("Restore or Delete Archived Items")
    }
    
    var message: Text {
        Text("Swipe left to right to Restore a habit. Swipe right to left to Delete a habit... forever")
    }
    
    var image: Image? {
        BJAsset.tip.image()
    }
}


struct ArchivedHabitsView: View {
    
    @EnvironmentObject var habitController: HabitController
    
    private let archiveTip = ArchiveTip()
    
    
    var body: some View {
        VStack {
//            TipView(archiveTip)
//                .padding()
            
            List {
                Section {
                    ForEach(habitController.latestArchivedHabits, id: \.id) { archivedHabit in
                        
                        Text("\(archivedHabit.name)")
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
                } footer: {
                    if habitController.latestArchivedHabits.isEmpty {
                        Text("There are no archived habits!")
                    }
                }
            }
        }

        .navigationTitle("Archived Habits")
        .navigationBarTitleDisplayMode(.inline)
    }
}


/*
 
 We want to get all of the archived habits
 This will require us to make a call to CoreData
 1. The fetch will be on Habits. It will look for everything with isArchived = true
 2. It should only change whenever we make an edit to the in-memory list. This will update by itself if we are doing only a swipe to restore/delete, but if we are going to do a context menu then we might need to do this differently. Lets keep it simple.
 3. It should not matter right now if we do this through the controller or not right? Well not so fast. We need to make sure that our app state is in the right place when we insert into core data. To ensure that, we will need to run this through HabitController.
 4. That being said, I only need to the UPDATES/DELETES through habitController. Just the other way, I can use a fetch straight to the database when we get this.
 5. Just for the sake of keeping everything in one place and having a list accessible easily, I'm going to go through habit controller for now. We will need it anyway.
 */


/*
 What is a bigger priority? Archiving Habits for sure. The Activity Details are not as front and center
 */

struct ArchivedActivityDetailsView: View {
    
    // MARK: Note This is a good place to put a TipKit for swiping to unarchive or delete
    @EnvironmentObject var habitController: HabitController
    
    private var archivedActivityDetails: [ActivityDetail] {
        habitController.archivedActivityDetails
    }
    
    private let archiveTip = ArchiveTip()
    
    var body: some View {
        
        VStack {
//            TipView(archiveTip)
//                .padding()
            
            List {
                SectionWithDisclaimerIfEmpty(
                    isEmpty: archivedActivityDetails.isEmpty,
                    
                    sectionContent: {
                        ForEach(archivedActivityDetails, id: \.id) { archivedActivityDetail in
    
                            Text("\(archivedActivityDetail.name)")
                                .swipeActions(edge: .leading) {
                                    // Restore
                                    Button {
                                        print("restore activity detail")
                                        habitController.restoreActivityDetail(archivedActivityDetail)
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
                                        print("delete activity detail")
                                        habitController.deleteActivityDetail(archivedActivityDetail)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    },
                    sectionHeader: {
                        EmptyView()
                    },
                    sectionEmpty: {
                        Text("There are no archived activity details!")
                    }
                )
//                SectionWithDisclaimerIfEmpty(isEmpty: archivedActivityDetails.isEmpty, sectionContent: {
//                    ForEach(archivedActivityDetails, id: \.id) { archivedActivityDetail in
//                        
//                        Text("\(archivedActivityDetail.name)")
//                            .swipeActions(edge: .leading) {
//                                // Restore
//                                Button {
//                                    print("restore activity detail")
//                                    habitController.restoreActivityDetail(archivedActivityDetail)
//                                } label: {
//                                    Label {
//                                        Text("Restore")
//                                    } icon: {
//                                        BJAsset.restore.image()
//                                    }
//                                }
//                                .tint(Color.restore)
//                            }
//                            .swipeActions(edge: .trailing) {
//                                // Delete
//                                Button(role: .destructive) {
//                                    print("delete activity detail")
//                                    habitController.deleteActivityDetail(archivedActivityDetail)
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                    }
//                }, sectionHeader: {
//                    Text("Header world")
//                }, sectionEmpty: {
//                    if archivedActivityDetails.isEmpty {
//                        Text("There are no archived activity details!")
//                    }
//                })
                
//                Section {
//                    ForEach(archivedActivityDetails, id: \.id) { archivedActivityDetail in
//                        
//                        Text("\(archivedActivityDetail.name)")
//                            .swipeActions(edge: .leading) {
//                                // Restore
//                                Button {
//                                    print("restore activity detail")
//                                    habitController.restoreActivityDetail(archivedActivityDetail)
//                                } label: {
//                                    Label {
//                                        Text("Restore")
//                                    } icon: {
//                                        BJAsset.restore.image()
//                                    }
//                                }
//                                .tint(Color.restore)
//                            }
//                            .swipeActions(edge: .trailing) {
//                                // Delete
//                                Button(role: .destructive) {
//                                    print("delete activity detail")
//                                    habitController.deleteActivityDetail(archivedActivityDetail)
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                    }
//                } footer: {
//                    if archivedActivityDetails.isEmpty {
//                        Text("There are no archived activity details!")
//                    }
//                }
            }
        }
        .navigationTitle("Archived Habits")
        .navigationBarTitleDisplayMode(.inline)
    }
}




struct SettingsView: View {
    
    var body: some View {
        
        List {
            // Section for archived stuff
            Section("The Archive") {
                NavigationLink("Archived Habits", destination: ArchivedHabitsView())
                NavigationLink("Archived Activity Details", destination: ArchivedActivityDetailsView())
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
