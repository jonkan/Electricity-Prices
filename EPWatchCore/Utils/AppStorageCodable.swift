//
//  AppStorageCodable.swift
//  Ranger
//
//  Created by Jonas Bromö on 2022-07-13.
//

import SwiftUI

@propertyWrapper
public struct AppStorageCodable<Value: Codable>: DynamicProperty {
    let key: String
    var storage: UserDefaults

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        wrappedValue: Value,
        _ key: String,
        storage: UserDefaults = .standard
    ) {
        self.key = key
        self.storage = storage
        _wrappedValue = wrappedValue
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    private var _wrappedValue: Value
    public var wrappedValue: Value {
        get {
            do {
                guard let data = storage.value(forKey: key) as? Data else {
                    return _wrappedValue
                }
                let value = try decoder.decode(Value.self, from: data)
                return value
            } catch {
                LogError(error)
                return _wrappedValue
            }
        }
        
        set {
            do {
                let data = try encoder.encode(newValue)
                storage.set(data, forKey: key)
                _wrappedValue = newValue
            } catch {
                LogError(error)
            }
        }
    }
}
