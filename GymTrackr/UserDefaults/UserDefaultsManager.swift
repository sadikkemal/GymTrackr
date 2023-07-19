//
//  UserDefaultsManager.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Foundation

final class UserDefaultsManager {

    // MARK: Internal
    static let shared = UserDefaultsManager()

    @UserDefault(key: "ongoingProgramDraft", defaultValue: nil)
    var ongoingProgramDraft: Program.Draft?

    // MARK: Lifecycle
    private init() { }
}
