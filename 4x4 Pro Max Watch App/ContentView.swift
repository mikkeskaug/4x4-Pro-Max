//
//  ContentView.swift
//  4x4 Pro Max Watch App
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Int = 0
    @StateObject var manager = WorkoutManager()
    var body: some View {
        TabView {
            ControlsView(selectedTab: $selectedTab, manager: manager)
                .tabItem {
                    Label("Controls", systemImage: "dot.fill")
                }
            WorkoutView(manager: manager, selectedTab: $selectedTab)
                .tabItem {
                    Label("Workout", systemImage: "dot.fill")
                }
            
        }
    }
}

#Preview {
    ContentView()
}
