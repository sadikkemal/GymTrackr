//
//  UserDefaultPropertyWrappers.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import Foundation

// MARK: - UserDefaultPrimitive
@propertyWrapper
struct UserDefaultPrimitive<Value> {

    // MARK: Internal
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        publisher.eraseToAnyPublisher()
    }

    // MARK: Private
    private let publisher = PassthroughSubject<Value, Never>()

}

// MARK: - UserDefault
@propertyWrapper
struct UserDefault<Value: Codable> {

    // MARK: Internal
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            guard let encodedAnyValue = container.object(forKey: key) else { return defaultValue }
            let encodedValue = encodedAnyValue as! Data
            let value = try! JSONDecoder().decode(Value.self, from: encodedValue)
            return value
        }
        set {
            let encodedNewValue = try! JSONEncoder().encode(newValue)
            container.set(encodedNewValue, forKey: key)
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        publisher.eraseToAnyPublisher()
    }

    // MARK: Private
    private let publisher = PassthroughSubject<Value, Never>()
}
