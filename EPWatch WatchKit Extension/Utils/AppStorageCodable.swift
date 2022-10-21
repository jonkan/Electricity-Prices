//
//  AppStorageCodable.swift
//  Ranger
//
//  Created by Jonas Bromö on 2022-07-13.
//

import SwiftUI

@propertyWrapper struct AppStorageCodable<Value: Codable>: DynamicProperty {
    let key: String
    var storage: UserDefaults
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(_ key: String, storage: UserDefaults = .standard) {
        self.key = key
        self.storage = storage
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    var wrappedValue: Value? {
        get {
            do {
                let data = storage.value(forKey: key) as? Data
                let value = try decode(data: data)
                return value
            } catch {
                LogError(error)
                return nil
            }
        }
        nonmutating set {
            do {
                let data = try encode(value: newValue)
                storage.set(data, forKey: key)
            } catch {
                LogError(error)
            }
        }
    }
    
    func encode(value: Value?) throws -> Data? {
        guard let value = value else { return nil }
        let data = try encoder.encode(value)
        return data
    }
    
    func decode(data: Data?) throws -> Value? {
        guard let data = data else { return nil }
        let value = try decoder.decode(Value.self, from: data)
        return value
    }
}
