//
//  View+ShowAlertDetail.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import SwiftUI



extension View {
    
    @ViewBuilder
    func alert(showAlert: Binding<Bool>, alertDetail: AlertDetail?) -> some View {
        
        if let alertDetail {
            alert(
                alertDetail.title,
                isPresented: showAlert,
                presenting: alertDetail,
                actions: { data in
                    ForEach(alertDetail.actions, id: \.self) { alertAction in
                        Button(alertAction.title, role: alertAction.role, action: alertAction.action)
                    }
                }, message: { data in
                    Text(data.message)
                }
            )
        } else {
            alert("Unknown Issue", isPresented: showAlert, actions: { }, message: {
                Text("Some problem has occurred with displaying an error alert - that's weird.")
            })
        }
    }
}
