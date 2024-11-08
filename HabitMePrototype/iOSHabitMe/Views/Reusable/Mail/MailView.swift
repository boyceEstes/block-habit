//
//  MailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 11/8/24.
//
import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?

    var recipients: [String]
    var subject: String
    var body: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer { parent.presentation.wrappedValue.dismiss() }
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
