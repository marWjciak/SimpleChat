//
//  AppSettings.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 19/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation

final class AppSettings {
    private enum SettingKey: String {
        case displayName
    }

    static var displayName: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingKey.displayName.rawValue)
        }

        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.displayName.rawValue

            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
