//
//  UIViewController.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 19/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
