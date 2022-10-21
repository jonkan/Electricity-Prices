//
//  ContentView.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-08-25.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var state: AppState = .shared

    var body: some View {
        Text("Current price: \(state.currentPrice ?? -1)")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
