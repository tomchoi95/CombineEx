//
//  FocusStateExample.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-03.
//

import SwiftUI

struct FocusStateExample: View {
    enum Field: Hashable {
        case username
        case password
        case field3
        case field4
    }
    
    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            
            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.done)
                .onSubmit { focusedField = nil }
            
            VStack(spacing: 20) {
                Button("Focus Username") { focusedField = .username }
                    .buttonStyle(BorderedButtonStyle())
                
                Button("Focus Password") { focusedField = .password }
                    .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    FocusStateExample()
}
