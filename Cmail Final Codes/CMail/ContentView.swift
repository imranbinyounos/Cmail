//
//  ContentView.swift
//  CMail
//
//  Created by Imran on 5/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var emailStore = EmailStore()
    @StateObject private var writingStylesStore = WritingStylesStore()
    @State private var selectedTab: Tab = .generator
    @StateObject private var draftStore = DraftStore()
    
    enum Tab: String, CaseIterable {
        case generator = "Generator"
        case styles = "Writing Styles"
        case saved = "Saved Emails"
        case drafts = "Drafts"
        
        var icon: String {
            switch self {
            case .generator: return "envelope.fill"
            case .styles: return "book.fill"
            case .saved: return "folder.fill"
            case .drafts: return "pencil.and.outline"
            }
        }
    }
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            // Sidebar
            List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    HStack {
                        Image(systemName: tab.icon)
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text(tab.rawValue)
                            .foregroundColor(.white)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200, maxWidth: 250)
            .background(Color.black)
        } detail: {
            // Main content area
            mainContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .environmentObject(draftStore)
        .navigationSplitViewStyle(.balanced)
        .preferredColorScheme(.dark)
        .background(Color.black)
        #else
        // iOS version - Clean TabView without any macOS influence
        TabView {
            EmailGeneratorView()
                .environmentObject(writingStylesStore)
                .tabItem {
                    Image(systemName: "envelope.fill")
                    Text("Generator")
                }
            
            WritingStylesView()
                .environmentObject(writingStylesStore)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Styles")
                }
            
            SavedEmailsView()
                .environmentObject(emailStore)
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Saved")
                }
            DraftsView()
                .environmentObject(draftStore)
                .tabItem {
                    Image(systemName: "pencil.and.outline")
                    Text("Drafts")
                }
        }
        .accentColor(.blue)
        .preferredColorScheme(.dark)
        #endif
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedTab {
        case .generator:
            EmailGeneratorView()
                .environmentObject(emailStore)
                .environmentObject(writingStylesStore)
        case .styles:
            WritingStylesView()
                .environmentObject(writingStylesStore)
        case .saved:
            SavedEmailsView()
                .environmentObject(emailStore)
        case .drafts:
            DraftsView()
                .environmentObject(draftStore)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(EmailStore())
        .environmentObject(WritingStylesStore())
}
