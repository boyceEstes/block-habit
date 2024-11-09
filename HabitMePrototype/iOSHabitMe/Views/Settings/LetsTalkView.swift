//
//  LetsTalkView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 11/8/24.
//

import SwiftUI
import MessageUI


enum MailStatus: Equatable {
    
    case success(MFMailComposeResult)
    case failure(String)
}


struct LetsTalkView: View {
    
    @State private var showingMailView = false
    @State private var mailResult: MailStatus? = nil
    
    
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        
        SettingsRow(imageSystemName: "hammer.fill", label: "Contact Developer", color: .emailMe, showDisclosure: false) {
            
            if MFMailComposeViewController.canSendMail() {
                showingMailView = true
            } else {
                // trigger alert
                showError = true
                errorMessage = "Cannot send mail - check your email account settings"
            }
        }
        .onChange(of: mailResult, { _, newValue in
            
            if case let .failure(errorResult) = newValue {
                showError = true
                errorMessage = "\(errorResult)"
            }
        })
        .sheet(isPresented: $showingMailView) {
            MailView(
                result: $mailResult,
                recipients: ["estes.boyce@gmail.com"],
                subject: "",
                body: ""
            )
        }
        .alert(
            errorMessage,
            isPresented: $showError,
            actions: {}
        )
    }
}


#Preview {
    LetsTalkView()
}
