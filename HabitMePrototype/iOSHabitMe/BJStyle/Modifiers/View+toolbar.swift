//
//  View+toolbar.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI



extension View {
    
    @ViewBuilder func sheetyTopBarNav(
        title: String,
        subtitle: String? = nil,
        dismissAction: @escaping () -> Void
    ) -> some View {
        
        modifier(
            SheetyTopBarNav(
                title: title,
                subtitle: subtitle,
                dismissAction: dismissAction
            )
        )
    }
    
    
    /// Template so that we can easily insert into the navigation bar setup that is being used throughout the app
    @ViewBuilder
    fileprivate func topBar<TopBarLeadingContent: View, TopBarTrailingContent: View>(
        @ViewBuilder topBarLeadingContent: @escaping () -> TopBarLeadingContent,
        @ViewBuilder topBarTrailingContent: @escaping  () -> TopBarTrailingContent
    ) -> some View {
        
        modifier(
            TopBar(
                topBarLeadingContent: topBarLeadingContent,
                topBarTrailingContent: topBarTrailingContent
            )
        )
    }
    
    
    /// Template for bottom bar - maybe a little pedantic but I don't like typing this out
    @ViewBuilder
    func bottomBar<BottomBarContent: View>(
        @ViewBuilder bottomBarContent: @escaping () -> BottomBarContent
    ) -> some View {
        modifier(
            BottomBar(
                bottomBarContent: bottomBarContent
            )
        )
    }
}


struct SheetyTopBarNav: ViewModifier {
    
    let title: String
    let subtitle: String?
    let dismissAction: () -> Void
    
    func body(content: Content) -> some View {
        
        content
            .topBar {
                VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
                    Text(title)
                        .font(.navTitle)
                    if let subtitle {
                        Text(subtitle)
                            .font(.navSubtitle)
                    }
                }
            } topBarTrailingContent: {
                HabitMeSheetDismissButton(dismiss: dismissAction)
            }

    }
}


struct TopBar<TopBarLeadingContent: View, TopBarTrailingContent: View>: ViewModifier {
    
    let topBarLeadingContent: () -> TopBarLeadingContent
    let topBarTrailingContent: () -> TopBarTrailingContent
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    topBarLeadingContent()
//                        .font(.navTitle)
                        .padding(.vertical)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    topBarTrailingContent()
                }
            }
    }
}


struct BottomBar<BottomBarContent: View>: ViewModifier {
    
    let bottomBarContent: () -> BottomBarContent
    
    func body(content: Content) -> some View {
        content
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                bottomBarContent()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Hello world")
            .topBar {
                Text("Title")
            } topBarTrailingContent: {
                Text("Trailing")
            }
            .bottomBar {
                
            }
    }
}
