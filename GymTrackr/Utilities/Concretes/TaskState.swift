//
//  TaskState.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Foundation

enum TaskState<T: Error> {
    case loading
    case success
    case failure(error: T)
}
