//
//  ExerciseInputCellContentConfiguration.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Foundation
import UIKit

// MARK: - ExerciseInputCellContentConfiguration
struct ExerciseInputCellContentConfiguration: Hashable {

    let id: Int
    let text: String
    let selectedOption: Int
}

// MARK: - UIContentConfiguration
extension ExerciseInputCellContentConfiguration: UIContentConfiguration {

    func makeContentView() -> UIView & UIContentView {
        ExerciseInputCellContentView(configuration: self)
    }

    func updated(for _: UIConfigurationState) -> Self {
        self
    }
}
