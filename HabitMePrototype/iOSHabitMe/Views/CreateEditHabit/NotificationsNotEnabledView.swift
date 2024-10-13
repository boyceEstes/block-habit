//
//  NotificationsNotEnabledView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI

struct NotificationsNotEnabled: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                Text("Notifications Are Not Enabled")
            }
            .font(.headline)
            
            Text("Not to point fingers, but at some point you told Apple that Block Habit couldn't send you notifications... Well, reminders kinda need that.\n\nDon't worry, we can fix this. Together. Tap here, and go to the app settings.")
            
            Button("Go to Allow Notifications") {
                openAppSettings()
            }
            .buttonStyle(.borderedProminent)
            .hAlign(.center)
        }
    }
    
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, completionHandler: { success in
                print("Settings opened: \(success)") // Print success/failure
            })
        }
    }
}

#Preview {
    NotificationsNotEnabled()
}
