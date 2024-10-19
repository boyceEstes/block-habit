//
//  InAppNotificationsNotEnabledView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/19/24.
//

import SwiftUI

struct InAppNotificationsNotEnabledView: View {
    
    let enableInAppNotifications: () -> Void
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                Text("In-App Notifications Are Disabled")
            }
            .font(.headline)
            
            Text("You have disabled notifications in the app. Reenable notifications to allow")
                .font(.subheadline)
            
            Button("Allow Notifications In App", action: enableInAppNotifications)
            .buttonStyle(.borderedProminent)
            .hAlign(.center)
        }
    }
}

#Preview {
    Form {
        InAppNotificationsNotEnabledView(enableInAppNotifications: { })
    }
}
