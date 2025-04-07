//
//  SignUpForm.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-07.
//

import SwiftUI
import Combine



struct SignUpForm: View {
    
    @Binding var willBeBinded: String
    
    var body: some View {
        Form {
            idSection
            passwordSection
            confirmButton
        }
    }
    
    private var idSection: some View {
        Section {
            TextField("Username", text: $willBeBinded)
                .autocorrectionDisabled()
        } footer: {
            Text(verbatim: "error")
                .foregroundStyle(.red)
        }
    }
    private var passwordSection: some View {
        Section {
            SecureField("Password", text: $willBeBinded)
            SecureField("Password Confirmation", text: $willBeBinded)
        }
    }
    private var confirmButton: some View {
        Section {
            Button("Sin in?") {
                
            }
//            .disabled(<#T##disabled: Bool##Bool#>)
        }
    }
    
}

#Preview {
    SignUpForm(willBeBinded: .constant(""))
}
