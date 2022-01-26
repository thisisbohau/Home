//
//  HomeTVApp.swift
//  HomeTV
//
//  Created by David Bohaumilitzky on 16.06.21.
//

import SwiftUI

@main
struct HomeTVApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Updater())
        }
    }
}
