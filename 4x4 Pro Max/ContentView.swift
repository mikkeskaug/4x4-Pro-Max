//
//  ContentView.swift
//  4x4 Pro Max
//
//  Created by Jon Mikael Skaug on 28/3/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
            GroupBox(label: Text("Søk")) {
                        TextField("Søk", text: .constant(""))
                    }
            GroupBox(label: Text("Treningsøkter")) {
                    List {
                    Text("❤️avg = 165 bpm, distance: 5km, ")
                }
                    
                }
            
                
            
            }
            .padding()
            .navigationTitle("4x4 Pro Max")
        }
        
        
    }
}

#Preview {
    ContentView()
        
}
