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
        Group {
            if let price = state.formattedCurrentPrice {
                Text(price)

            } else {
                Text("Loading current price...")
            }
        }
        .padding()
        .onAppear {
            state.updateCurrentPrice()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
