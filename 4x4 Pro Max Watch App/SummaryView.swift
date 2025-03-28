//
//  SummaryView.swift
//  4x4 Pro Max Watch App
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import SwiftUI

struct SummaryView: View {
    @ObservedObject var manager: WorkoutManager
    var body: some View {
        Text("Workout Summary")
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(String(format: "Total distance: %.2f km", manager.distance / 1000))
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(String(format: "Avg speed: %.2f km/h", manager.averageSpeed * 3.6))
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
        Text("Avg HR: \(Int(manager.heartRate)) bpm")
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SummaryView(manager: WorkoutManager())
}
