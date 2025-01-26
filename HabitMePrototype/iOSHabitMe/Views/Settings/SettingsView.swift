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
        Group {
            if !archivedActivityDetails.isEmpty {
                List {
                    ForEach(archivedActivityDetails, id: \.id) { archivedActivityDetail in
                        
                        ArchivedItemRow(name: archivedActivityDetail.name) {
                            habitController.deleteActivityDetail(archivedActivityDetail)
                        } restoreItem: {
                            habitController.restoreActivityDetail(archivedActivityDetail)
                        }
                        .swipeActions(edge: .leading) {
                            // Restore
                            Button {
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
                                habitController.deleteActivityDetail(archivedActivityDetail)
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
                    
                    Text("No Archived Details")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    
                    VStack {
                        Text("Come back after you've archived a detail")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                    }

                }
                .padding(.horizontal)
            }
        }
//        VStack {
////            TipView(archiveTip)
////                .padding()
//            
//            List {
//                SectionWithDisclaimerIfEmpty(
//                    isEmpty: archivedActivityDetails.isEmpty,
//                    
//                    sectionContent: {
//                        ForEach(archivedActivityDetails, id: \.id) { archivedActivityDetail in
//    
//                            Text("\(archivedActivityDetail.name)")
//                                .swipeActions(edge: .leading) {
//                                    // Restore
//                                    Button {
//                                        print("restore activity detail")
//                                        habitController.restoreActivityDetail(archivedActivityDetail)
//                                    } label: {
//                                        Label {
//                                            Text("Restore")
//                                        } icon: {
//                                            BJAsset.restore.image()
//                                        }
//                                    }
//                                    .tint(Color.restore)
//                                }
//                                .swipeActions(edge: .trailing) {
//                                    // Delete
//                                    Button(role: .destructive) {
//                                        print("delete activity detail")
//                                        habitController.deleteActivityDetail(archivedActivityDetail)
//                                    } label: {
//                                        Label("Delete", systemImage: "trash")
//                                    }
//                                }
//                        }
//                    },
//                    sectionHeader: {
//                        EmptyView()
//                    },
//                    sectionEmpty: {
//                        Text("There are no archived activity details!")
//                    }
//                )
//            }
//        }
        .navigationTitle("Archived Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ThanksView: View {
    
    let didTapClose: () -> Void
    
    
    var body: some View {
        VStack(spacing: 8) {
              
              Text("Thank You 💕")
                  .font(.system(.title2, design: .rounded).bold())
                  .multilineTextAlignment(.center)
              
              Text("Thank you so much for your support! Your generosity means the world and helps keep this project going strong. Seriously, you're making a difference. Thank you for being awesome!")
                  .font(.system(.body, design: .rounded))
                  .multilineTextAlignment(.center)
                  .padding(.bottom, 16)
              
              Button(action: didTapClose) {
                  Text("Close")
                      .font(.system(.title3, design: .rounded).bold())
                      .tint(.white)
                      .frame(height: 55)
                      .frame(maxWidth: .infinity)
                      .background(.blue, in: RoundedRectangle(cornerRadius: 10,
                                                              style: .continuous))
              }
          }
          .padding(16)
          .background(Color(UIColor.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
          .padding(.horizontal, 8)
    }
}

// No because this doesn't work for Settings. Where this is tapped.
// I need something that when tapped on the row. Will update this view accordingly.
// Like a settings wrapper for everything - then a settings donation view

/*
 By having a settingscontainerview I can make all of the settings stuff work the same way but now
 I can have a donation logic that is separate. This means that if I ever want to bring this to another
 app I can simply move this container view instead of needing to bring everything.
 
 Then we can just trigger things to happen in the closure that we pass to the settingsview and mkae it
 modify this page
 */
struct SettingsContainerView: View {
    
    // MARK: Environment Properties
    @EnvironmentObject var store: TipStore
    // MARK: Injected Properties
    let goToNotifications: () -> Void
    let goToArchivedHabits: () -> Void
    let goToArchivedActivityDetails: () -> Void
    
    @State private var isShowingDonationView = false
    @State private var isShowingThankYouView = false
    
    
    var body: some View {
        
        SettingsView(
            goToNotifications: goToNotifications,
            goToArchivedHabits: goToArchivedHabits,
            goToArchivedActivityDetails: goToArchivedActivityDetails,
            goToBuyMeACoffee: showDonationView
        )
            .overlay {
                
                if isShowingDonationView {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            isShowingDonationView.toggle()
                            
                        }
                    DonationView{
                        isShowingDonationView.toggle()
                    } // Might need a way to tell it to get the fuck off
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            .overlay(alignment: .bottom) {

                if isShowingThankYouView {
                    
                    ThanksView { isShowingThankYouView = false }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(), value: isShowingDonationView)
            .animation(.spring(), value: isShowingThankYouView)
        
            .onChange(of: store.action) { _, newValue in
                
                if newValue == .successful {
                    
                    isShowingDonationView = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        isShowingThankYouView = true
                        store.reset()
                    }
                }
            }
            .navigationBarBackButtonHidden(isShowingDonationView)
            .alert(isPresented: $store.hasError, error: store.error, actions: {})
    }
    
    
    func showDonationView() {
        
        // Present that overlap. Do it snappy
        isShowingDonationView = true
    }
}


struct SettingsView: View {
    
    // MARK: Injected Properties
    let goToNotifications: () -> Void
    let goToArchivedHabits: () -> Void
    let goToArchivedActivityDetails: () -> Void
    let goToBuyMeACoffee: () -> Void
    // MARK: View Properties
    @State private var showDonation = false
    @State private var showThanks = false
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
                    label: "Archived Details",
                    color: .archivedActivityDetails,
                    tapAction: goToArchivedActivityDetails
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
                    label: "Buy Me a Coffee",
                    color: .pink,
                    showDisclosure: false,
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
            goToBuyMeACoffee: { }
        )
    }
}
