//
//  ArchivedItemRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/19/24.
//

import SwiftUI

struct ArchivedItemRow: View {
    
    let name: String
    let deleteItem: () -> Void
    let restoreItem: () -> Void
    
    
    var body: some View {
        HStack {
            Text("\(name)")
            Spacer()
            HStack(spacing: 16) {
                Button(action: deleteItem) {
                    LittleImage(imageSystemName: "trash", color: .red)
                }
                Button(action: restoreItem) {
                    Text("Restore")
                }
            }
        }
    }
}

#Preview {
    ArchivedItemRow(name: "Bathe Shark", deleteItem: { }, restoreItem: { })
}
