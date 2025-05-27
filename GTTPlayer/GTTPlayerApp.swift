//
//  GTTPlayerApp.swift
//  GTTPlayer
//
//  Created by Javier Godoy Núñez on 5/27/25.
//

import SwiftUI
import GoogleCast

@main
struct GTTPlayerApp: App {
    // Use UIApplicationDelegateAdaptor to integrate the AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PlaylistListView()
                    .tabItem {
                        Label("Playlists", systemImage: "list.bullet")
                    }
                
                SpringfieldStreamsView()
                    .tabItem {
                        Label("Streams", systemImage: "play.tv")
                    }
            }
        }
    }
}
