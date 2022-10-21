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
        if let price = state.formattedCurrentPrice {
            Text(price)
                .padding()
        } else {
            Text("Loading current price...")
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
