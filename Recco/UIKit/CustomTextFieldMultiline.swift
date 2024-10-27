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
    let isSectionTitle: Bool
    @Binding var currentIndex: ListFocusIndex
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?
    var onBackspaceEmptyString: (() -> Void)?
    
    @EnvironmentObject var listViewModel: ListViewModel
    
    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        textField.addGestureRecognizer(tapGesture)
              
        textField.delegate = context.coordinator
        
        textField.isEditable = true
        textField.textColor = foregroundColor
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.font = font
        if(!self.isSectionTitle){
            addSwiftUIButtonToToolbar(textView: textField, currentIndex: currentIndex)
        }

        return textField
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
                   uiView.text = self.text
               }
        if(!uiView.isFirstResponder && self.shouldBeFirstResponder()){
            uiView.becomeFirstResponder()
            DispatchQueue.main.async{
                if(!self.isSectionTitle){
                    addSwiftUIButtonToToolbar(textView: uiView, currentIndex: currentIndex)
                }
            }
        } else if(self.currentIndex == nil){
            if self.currentIndex == nil {
            uiView.resignFirstResponder()
                }
            }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }
    
    private func createToolbarHostingController() -> UIHostingController<ListKeyboardButtons> {
           return UIHostingController(
            rootView: ListKeyboardButtons(currentIndex: self.$currentIndex)
           )
           
       }
    
    func addSwiftUIButtonToToolbar(textView: UITextView, currentIndex: ListFocusIndex) {
        let toolbar = UIToolbar()

        // Create a UIHostingController for your SwiftUI view
        let buttonsView = ListKeyboardButtons(currentIndex: $currentIndex).environmentObject(listViewModel)
        let hostingController = UIHostingController(rootView: buttonsView)

        // Add the hosting controller’s view to the UIToolbar
        toolbar.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints for the SwiftUI view in the UIToolbar
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: toolbar.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor)
        ])

        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
    }
    
    private func shouldBeFirstResponder()->Bool{
        if let listIndex = currentIndex{
            return (selfSectionIndex == listIndex.section && selfIndex == listIndex.index && isDescription == listIndex.isDescription)
        }
        return false
    }
    
    func handleTapGesture(){
        self.currentIndex = (section: selfSectionIndex, index: selfIndex, isDescription: isDescription, isSectionTitle: false)
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
        return Coordinator(
            text: $text,
            height: $calculatedHeight,
            onDone: onDone,
            onTap: handleTapGesture,
            onBackspaceEmptyString: onBackspaceEmptyString
        )
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        var onTap: () -> Void
        var onBackspaceEmptyString: (() -> Void)?

        
        init(text: Binding<String>,
             height: Binding<CGFloat>,
             onDone: (() -> Void)? = nil,
             onTap: @escaping () -> Void,
             onBackspaceEmptyString: (() -> Void)? = nil
        ) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
            self.onTap = onTap
            self.onBackspaceEmptyString = onBackspaceEmptyString
        }
        
        // Step 2: Implement the tap gesture handler method
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                    onTap()
                }
        
        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                    onDone()
                textView.superview?.layoutIfNeeded()
                return false
            }
            print(textView.text, "text")
            if let onBackspaceEmptyString = self.onBackspaceEmptyString, text == "" && textView.text.isEmpty {
                onBackspaceEmptyString()
                textView.superview?.layoutIfNeeded()
                return false
            }
            return true;
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
    let isSectionTitle: Bool
    let textFontSize: CGFloat
    @Binding var currentIndex: ListFocusIndex
    private var onCommit: (() -> Void)
    private var onBackspaceEmptyString: (() -> Void)
    
    @EnvironmentObject var listViewModel: ListViewModel
    
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
          isSectionTitle: Bool,
          currentIndex: Binding<ListFocusIndex>,
          onCommit: @escaping (() -> Void),
          onBackspaceEmptyString: @escaping (() -> Void)
    ) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.onBackspaceEmptyString = onBackspaceEmptyString
        self._text = text
        self.foregroundColor=foregroundColor
        self.fontString = fontString
        self.selfIndex = selfIndex
        self.selfSectionIndex = selfSectionIndex
        self.isDescription = isDescription
        self.isSectionTitle = isSectionTitle
        self._currentIndex=currentIndex
        if(isSectionTitle){
            self.textFontSize = 24
        } else if (self.isDescription) {
            self.textFontSize = 14
        } else {
            self.textFontSize = 18
        }
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
        
    }
    
    var body: some View {
        HStack(spacing: 0){
        UITextViewWrapper(text: self.internalText,
                          foregroundColor: UIColor(foregroundColor),
                          font: UIFont(name: fontString,
                                       size: self.textFontSize
                                      )!,
                          selfIndex: selfIndex,
                          selfSectionIndex: selfSectionIndex,
                          isDescription: isDescription,
                          isSectionTitle: isSectionTitle,
                          currentIndex: $currentIndex,
                          calculatedHeight: $dynamicHeight,
                          onDone: onCommit,
                          onBackspaceEmptyString: onBackspaceEmptyString
        )
        .environmentObject(listViewModel)
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        .background(placeholderView, alignment: .leading)
        }
    }
    
    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .font(.custom(fontString, size: isDescription ? 14 : isSectionTitle ? 22 : 18))
                    .fontWeight( isDescription ? .regular : .bold)
                    .padding(.leading, 5)
            }
        }
    }
}
