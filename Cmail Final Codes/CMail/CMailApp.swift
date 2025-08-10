//
//  CMailApp.swift
//  CMail
//
//  Created by Imran on 5/8/25.
//

import SwiftUI

@main
struct CMailApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(width: 1400, height: 900)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
        #endif
    }
}
