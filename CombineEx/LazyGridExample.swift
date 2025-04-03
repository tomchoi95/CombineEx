//
//  LazyGridExample.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-03.
//

import SwiftUI

struct LazyGridExample: View {
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0 ..< 50) { index in
                    Text("Item \(index)")
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    LazyGridExample()
}
