//
//  SwiftUIView.swift
//  4x4 Pro Max Watch App
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import SwiftUI

struct ControlsView: View {
    @Binding var selectedTab: Int
    @StateObject var manager = WorkoutManager()
    @State private var showStopAlert = false

    var body: some View {
        VStack {
            if !manager.workoutActive {
                Button("Start Workout") {
                    manager.startWorkout()
                    print("Manager active")
                    selectedTab = 1
                }
            } else {
                Button("Pause Workout") {
                    manager.pauseWorkout()
                }
                .foregroundColor(.orange)
            }
            if manager.workoutActive {
                
            
            Button("Stop Workout") {
                showStopAlert = true
            }
            .foregroundColor(.red)
            .alert(isPresented: $showStopAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("This will save the workout and reset"),
                    primaryButton: .destructive(Text("Stop")) {
                        manager.stopWorkout()
                    },
                    secondaryButton: .cancel()
                )
            }
            }
        }
    }
}

#Preview {
    ControlsView(selectedTab: .constant(0))
}
