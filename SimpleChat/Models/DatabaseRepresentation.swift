//
//  DatabaseRepresentation.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 19/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation

protocol DatabaseRepresentation {
    var representation: [String : Any] { get }
}
