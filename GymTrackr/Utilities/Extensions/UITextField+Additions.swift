//
//  UITextField+Additions.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

extension UITextField {

    var didChangeTextPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: Self.textDidChangeNotification, object: self)
            .compactMap { $0.object as? Self }
            .map { $0.text ?? String() }
            .eraseToAnyPublisher()
    }

    var didBeginEditingTextPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: Self.textDidBeginEditingNotification, object: self)
            .compactMap { $0.object as? Self }
            .map { $0.text ?? String() }
            .eraseToAnyPublisher()
    }

    var didEndEditingTextPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: Self.textDidEndEditingNotification, object: self)
            .compactMap { $0.object as? Self }
            .map { $0.text ?? String() }
            .eraseToAnyPublisher()
    }
}
