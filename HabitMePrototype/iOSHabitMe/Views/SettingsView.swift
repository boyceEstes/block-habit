//
//  SettingsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 5/14/24.
//

import SwiftUI


struct ArchivedHabitsView: View {
    
    var body: some View {
        
        Text("Show archived habits")
    }
}


struct ArchivedActivityDetailsView: View {
    
    var body: some View {
        
        Text("Show archived activity details")
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
