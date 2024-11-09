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
            }
        }
        .navigationTitle("Archived Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct SettingsView: View {
    
    // MARK: Injected Properties
    let goToNotifications: () -> Void
    let goToArchivedHabits: () -> Void
    let goToArchivedActivityDetails: () -> Void
    let goToLetsTalk: () -> Void
    let goToBuyMeACoffee: () -> Void
    // MARK: View Properties
    let reviewLink = URL(string: "https://apps.apple.com/app/6476879214?action=write-review")
    @Environment(\.openURL) var openURL
    
    var body: some View {
        
        List {
            Section {
                SettingsRow(
                    imageSystemName: "paperplane.fill",
                    label: "Notifications",
                    color: .notifications,
                    tapAction: goToNotifications
                )
            }
            // Section for archived stuff
            Section {
                SettingsRow(
                    imageSystemName: "archivebox.fill",
                    label: "Archived Habits",
                    color: .archivedHabits,
                    tapAction: goToArchivedHabits
                )
                SettingsRow(
                    imageSystemName: "archivebox.fill",
                    label: "Archived Activity Details",
                    color: .archivedActivityDetails,
                    tapAction: goToArchivedHabits
                )
            }
            
            Section {
                
                SettingsRow(
                    imageSystemName: "star.fill",
                    label: "Love this app? Share your Review!",
                    color: .rateApp,
                    showDisclosure: false,
                    tapAction: rateApp
                )
                
                LetsTalkView()
                
                SettingsRow(
                    imageSystemName: "cup.and.saucer.fill",
                    label: "🚧 Buy me a coffee 🚧",
                    color: .pink,
                    tapAction: sendMeMoney
                )
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    func rateApp() {
        if let link = reviewLink {
            openURL(link)
        }
    }
    
    
    func emailMe() {
        
        goToLetsTalk()
    }
    
    
    func sendMeMoney() {
        
        goToBuyMeACoffee()
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            goToNotifications: { },
            goToArchivedHabits: { },
            goToArchivedActivityDetails: { },
            goToLetsTalk: { },
            goToBuyMeACoffee: { }
        )
    }
}
