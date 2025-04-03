//
//  ScrollViewReaderEx.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-03.
//

import SwiftUI

struct ScrollViewReaderEx: View {
    @State private var selectedId = 0
    
    var body: some View {
        VStack {
            HStack {
                Button("Go to 10") {
                    withAnimation {
                        selectedId = 10
                    }
                }
                
                Button("Go to 50") {
                    withAnimation {
                        selectedId = 50
                    }
                }
                
                Button("Go to 75") {
                    withAnimation {
                        selectedId = 75
                    }
                }
            }
            
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(0 ..< 100) { id in
                            Text("Item \(id)")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background (id == selectedId ? Color.blue : Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                        }
                    }
                    .onChange(of: selectedId) { oldValue, newValue in
                      // proxy를 이용해 스크롤 위치를 변경합니다.
                      // easeInOut 애니메이션을 사용하여 부드럽게 스크롤합니다.
                      withAnimation(.easeInOut(duration: 1.0)) {
                        proxy.scrollTo(newValue, anchor: .center)
                      }
                    }
                  
                }
            }
        }
    }
}

#Preview {
    ScrollViewReaderEx()
}
