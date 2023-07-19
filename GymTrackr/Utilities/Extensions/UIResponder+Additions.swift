//
//  UIResponder+Additions.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

extension UIResponder {

    typealias UserInfo = [AnyHashable: Any]

    class var keyboardWillChangeFramePublisher: AnyPublisher<UserInfo, Never> {
        NotificationCenter.default
            .publisher(for: Self.keyboardWillChangeFrameNotification, object: nil)
            .compactMap { $0.userInfo }
            .eraseToAnyPublisher()
    }

    class var keyboardDidHidePublisher: AnyPublisher<UserInfo, Never> {
        NotificationCenter.default
            .publisher(for: Self.keyboardDidHideNotification, object: nil)
            .compactMap { $0.userInfo }
            .eraseToAnyPublisher()
    }

    class var keyboardWillShowPublisher: AnyPublisher<UserInfo, Never> {
        NotificationCenter.default
            .publisher(for: Self.keyboardWillShowNotification, object: nil)
            .compactMap { $0.userInfo }
            .eraseToAnyPublisher()
    }

    class func calculateContentInset(userInfo: UserInfo, containerView: UIView) -> UIEdgeInsets? {
        guard let keyboardValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return nil }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = containerView.convert(
            keyboardScreenEndFrame,
            from: containerView.window)
        let contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: containerView.frame.maxY - keyboardViewEndFrame.minY - containerView.safeAreaInsets.bottom,
            right: 0)
        return contentInset
    }
}
