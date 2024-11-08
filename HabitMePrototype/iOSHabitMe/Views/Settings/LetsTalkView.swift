//
//  LetsTalkView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 11/8/24.
//

import SwiftUI
import MessageUI

struct LetsTalkView: View {
    @State private var showingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        VStack {
            Button("Contact Us via Email") {
                if MFMailComposeViewController.canSendMail() {
                    showingMailView = true
                } else {
                    // Handle the case where email is not set up on the device
                    print("Cannot send email")
                }
            }
        }
        .sheet(isPresented: $showingMailView) {
            MailView(result: $mailResult, recipients: ["your_email@example.com"], subject: "Support Request", body: "Hi there,")
        }
    }
}

#Preview {
    LetsTalkView()
}
