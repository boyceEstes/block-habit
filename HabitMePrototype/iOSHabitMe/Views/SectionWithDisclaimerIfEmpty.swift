//
//  SectionWithDisclaimerIfEmpty.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 7/18/24.
//

import SwiftUI

struct SectionWithDisclaimerIfEmpty<SectionContent: View, SectionHeader: View, SectionEmpty: View>: View {
    
    let isEmpty: Bool
    @ViewBuilder let sectionContent: () -> SectionContent
    let sectionHeader: (() -> SectionHeader)?
    @ViewBuilder let sectionEmpty: () -> SectionEmpty
    
    init(
        isEmpty: Bool,
        @ViewBuilder sectionContent: @escaping () -> SectionContent,
        sectionHeader: (() -> SectionHeader)? = nil,
        @ViewBuilder sectionEmpty: @escaping () -> SectionEmpty
    ) {
        self.isEmpty = isEmpty
        self.sectionContent = sectionContent
        self.sectionHeader = sectionHeader
        self.sectionEmpty = sectionEmpty
    }
    
    var body: some View {
        
        Section {
            if !isEmpty {
                sectionContent()
            }
        } header: {
            sectionHeader?()
        } footer: {
            if isEmpty {
                sectionEmpty()
            }
        }
    }
}
