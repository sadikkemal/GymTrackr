//
//  TextFieldCellContentConfiguration.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Foundation
import UIKit

// MARK: - TextFieldCellContentConfiguration
struct TextFieldCellContentConfiguration: Hashable {

    // MARK: Internal
    let id: Int
    let placeholderText: String
    let text: String
    let keyboardType: UIKeyboardType

    // MARK: Lifecycle
    init(id: Int, placeholderText: String, text: String, keyboardType: UIKeyboardType = .default) {
        self.id = id
        self.placeholderText = placeholderText
        self.text = text
        self.keyboardType = keyboardType
    }
}

// MARK: - UIContentConfiguration
extension TextFieldCellContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        TextFieldCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }
}
