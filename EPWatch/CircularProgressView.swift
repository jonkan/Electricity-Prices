//
//  CircularProgressView.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-11-01.
//


import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    var color: Color = .accentColor
    var size: Double = 24
    var lineWidth: Double = 4

    init(progress: Double) {
        self.progress = progress
    }

    init(value: Int, total: Int) {
        progress = Double(value) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.4),
                    lineWidth: lineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
        .frame(width: size, height: size)
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
            CircularProgressView(progress: 0)
            CircularProgressView(progress: 0.4)
            CircularProgressView(progress: 1)
        }
    }
}

