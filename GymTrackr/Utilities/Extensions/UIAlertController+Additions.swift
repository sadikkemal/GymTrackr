//
//  UIAlertController.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import UIKit

extension UIViewController {

    func presentAlertController(for error: Error) {
        let alertController = UIAlertController(
            title: "An error occured!",
            message: error.localizedDescription,
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(
            title: "OK",
            style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}
