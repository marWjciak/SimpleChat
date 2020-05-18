//
//  ViewController.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.layer.cornerRadius = registerButton.frame.size.height * 0.50
        logInButton.layer.cornerRadius = registerButton.frame.size.height * 0.50
    }


}

