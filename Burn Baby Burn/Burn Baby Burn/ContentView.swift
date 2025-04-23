//
//  ContentView.swift
//  Burn Baby Burn
//
//  Created by Marek Sivak on 23/4/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "fork.knife")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("BBB!")
                .font(.custom("PressStart2P-Regular", size: 24))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
