//
//  ContentView.swift
//  4x4 Pro Max Watch App
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var manager: WorkoutManager
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text(manager.currentInterval?.name ?? "Ready")
                .font(.headline)
            
            Text("⏳ \(formatTime(manager.timeRemaining))")
                .font(.title2)
      
            Text("❤️ \(Int(manager.heartRate)) bpm")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)

            
            Text(String(format: "📍 %.2f km", manager.distance / 1000))
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(String(format: "🏃🏻 %.2f km/h", manager.speed * 3.6))
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding()
        .background(background)
        .sheet(isPresented: $manager.showSummary) {
            SummaryView(manager: manager)
        }
        
    }
    
    var background: Color {
        switch manager.currentInterval?.type {
        case .warmup:
            return Color.blue.opacity(0.25)
        case .run:
            return Color.green.opacity(0.25)
        case .jog:
            return Color.yellow.opacity(0.25)
        default:
            return Color.red.opacity(0.25)
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    WorkoutView(manager: WorkoutManager(), selectedTab: .constant(0))
}
