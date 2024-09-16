//
//  CustomTextField.swift
//  Recco
//
//  Created by Christen Xie on 9/7/24.
//


import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    let foregroundColor: Color
    let font: UIFont
    var onSubmit: () -> Void
    
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit()
            return false
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.textColor = UIColor(foregroundColor)
        textField.font = font
        textField.textAlignment = .left
        textField.allowsEditingTextAttributes = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.allowsEditingTextAttributes = false
           
        return textField
        
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}
