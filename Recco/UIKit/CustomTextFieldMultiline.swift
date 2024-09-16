//
//  CustomTextFieldMultiline.swift
//  Recco
//
//  Created by Christen Xie on 9/14/24.
//

import SwiftUI
import UIKit

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    let foregroundColor: UIColor
    let font: UIFont
    let selfIndex: Int
    let selfSectionIndex: Int?
    let isDescription: Bool
    @Binding var currentIndex: ListFocusIndex
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?
    
    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator
        
        textField.isEditable = true
        textField.textColor = foregroundColor
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.font = font
        
        let toolbarHostingController = createToolbarHostingController()
        toolbarHostingController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        textField.inputAccessoryView = toolbarHostingController.view
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
                   uiView.text = self.text
               }
        if(!uiView.isFirstResponder && self.shouldBeFirstResponder()){
            let toolbarHostingController = createToolbarHostingController()
            uiView.inputAccessoryView = toolbarHostingController.view
            uiView.reloadInputViews()
            DispatchQueue.main.async{
                uiView.becomeFirstResponder()
            }
        } else if(self.currentIndex == nil){
            uiView.resignFirstResponder()
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }
    
    private func createToolbarHostingController() -> UIHostingController<ListKeyboardButtons> {
           return UIHostingController(
               rootView: ListKeyboardButtons(currentIndex: self.currentIndex)
           )
       }
    
    private func shouldBeFirstResponder()->Bool{
        if let listIndex = currentIndex{
            return (selfSectionIndex == listIndex.section && selfIndex == listIndex.index && isDescription == listIndex.isDescription)
        }
        return false
    }
    
    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        
        init(text: Binding<String>,
             height: Binding<CGFloat>,
             onDone: (() -> Void)? = nil
        ) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }
        
        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                    onDone()
                return false
            }
            return true
        }
    }
    
}

struct CustomTextFieldMultiline: View {
    
    @Binding private var text: String
    let placeholder: String
    let foregroundColor: Color
    let fontString: String
    let selfIndex: Int
    let selfSectionIndex: Int?
    let isDescription: Bool
    @Binding var currentIndex: ListFocusIndex
    private var onCommit: (() -> Void)?
    
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }
    
    @State private var dynamicHeight: CGFloat = 60
    @State private var showingPlaceholder = false
    
    init (text: Binding<String>,
          placeholder: String,
          foregroundColor: Color,
          fontString: String,
          selfIndex: Int,
          selfSectionIndex: Int?,
          isDescription: Bool,
          currentIndex: Binding<ListFocusIndex>,
          onCommit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self.foregroundColor=foregroundColor
        self.fontString = fontString
        self.selfIndex = selfIndex
        self.selfSectionIndex = selfSectionIndex
        self.isDescription = isDescription
        self._currentIndex=currentIndex
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }
    
    var body: some View {
        UITextViewWrapper(text: self.internalText,
                          foregroundColor: UIColor(foregroundColor),
                          font: UIFont(name: fontString,
                                       size: isDescription ? 14 : 18
                                      )!,
                          selfIndex: selfIndex,
                          selfSectionIndex: selfSectionIndex,
                          isDescription: isDescription,
                          currentIndex: $currentIndex,
                          calculatedHeight: $dynamicHeight,
                          onDone: onCommit
        )
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        .background(placeholderView, alignment: .leading)
        .onTapGesture{
            self.currentIndex = (section: selfSectionIndex, index: selfIndex, isDescription: isDescription)
        }
    }
    
    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .font(.custom(fontString, size: isDescription ? 14 : 18))
                    .fontWeight( isDescription ? .regular : .bold)
                    .padding(.leading, 5)
            }
        }
    }
}
