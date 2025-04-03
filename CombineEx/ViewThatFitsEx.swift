//
//  ViewThatFitsEx.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-03.
//

import SwiftUI

struct ViewThatFitsEx: View {
    var body: some View {
        VStack {
            Text("ViewThatFits Example")
                .font(.title)
                .padding()
            
            ViewThatFits(in: .horizontal) {
                bigMode
                mediumMode
                smallMode
            }
            
            Spacer()
            
            Text("Try changing the screen sizee to see the view adapt")
                .font(.caption)
                .padding()
        }
    }
    
    var bigMode: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("This is the complete text that will be displayed if there's enough space")
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2)))
    }
    var mediumMode: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("Shorter text")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.8)))
    }
    var smallMode: some View {
        Text("Minimal")
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)))
    }
}

#Preview {
    ViewThatFitsEx()
}
