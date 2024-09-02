//
//  ElegantEmojiPickerView.swift
//  Recco
//
//  Created by Christen Xie on 9/1/24.
//

import ElegantEmojiPicker
import SwiftUI

struct ElegantEmojiPickerView: UIViewControllerRepresentable {
    
    @Binding var selectedEmoji: String?
    
    func makeUIViewController(context: Context) -> ElegantEmojiPicker {
        let picker = ElegantEmojiPicker(delegate: context.coordinator)
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ElegantEmojiPicker, context: Context) {
        // No need to update the UIViewController here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ElegantEmojiPickerDelegate {
        var parent: ElegantEmojiPickerView
        
        init(_ parent: ElegantEmojiPickerView) {
            self.parent = parent
        }
        
        func emojiPicker(_ picker: ElegantEmojiPicker, didSelectEmoji emoji: Emoji?) {
            parent.selectedEmoji = emoji?.emoji
        }
    }
}
