//
//  UITextfield+Extensions.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 7.06.2021.
//

import UIKit

extension UITextField {
    
    func addDoneButton() {
        let doneToolbar: UIToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        let items = [flexSpace, doneButton]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        inputAccessoryView = doneToolbar
    }
    
    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }
    
}
