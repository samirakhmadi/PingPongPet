//
//  UserSettings.swift
//  PingPong
//
//  Created by Samir Akhmadi on 18.09.2022.
//

import Foundation

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    @Published var reset: Bool {
        didSet {
            UserDefaults.standard.set(reset, forKey: "reset")
        }
    }
    init() {
        self.reset = UserDefaults.standard.object(forKey: "reset") as? Bool ?? true
    }
}
