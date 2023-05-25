//
//  EmojiKeyboard.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import Foundation
import UIKit
import SwiftUI

class UIEmojiTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEmoji() {
        _ = self.textInputMode
    }
    
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default
                return mode
            }
        }
        return nil
    }
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    var placeholder: String = ""
    let textField = UIEmojiTextField()
    
    func makeUIView(context: Context) -> UIEmojiTextField {
        textField.placeholder = placeholder
        textField.text = text
        textField.font = textField.font?.withSize(30)
        textField.textAlignment = .center
        textField.delegate = context.coordinator
        
        return textField
    }
    
    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(parent: EmojiTextField) {
            self.parent = parent
            
            super.init()
            
            let bar = UIToolbar()
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
            bar.items = [done]
            bar.sizeToFit()
            parent.textField.inputAccessoryView = bar
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.text = textField.text ?? ""
            }
        }
        
        @objc
        func doneTapped() {
            parent.focused.wrappedValue = false
        }
    }
}
