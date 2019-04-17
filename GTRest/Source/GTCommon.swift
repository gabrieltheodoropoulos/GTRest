//
//  GTCommon.swift
//  GTRest
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Gabriel Theodoropoulos. All rights reserved.
//

import Foundation

// MARK: - GTStringRepresentable Protocol

/**
 It provides common String based operations to Enums.
 
 List of provided operations:
 
 * `casesCollection()`: Get all Enum cases as a collection of String items.
 * `toString()`: Get a String representation of the current value
 
 - Precondition:
 Any Enum that adopts this protocol must also adopt to `CaseIterable`.
 */
protocol GTStringRepresentable {
    func casesCollection() -> [String]
    func toString() -> String
}


extension GTStringRepresentable where Self: CaseIterable {
    /**
     It returns an array with cases as String values.
     */
    func casesCollection() -> [String] {
        return Self.allCases.map { "\($0)" }
    }
    
    
    /**
     A String representation of the current case.
     */
    func toString() -> String {
        return casesCollection().filter { $0 == "\(self)" }[0]
    }
}



// MARK: - GTAssistiveTools Protocol

protocol GTAssistiveTools {
    /// :nodoc:
    func generateRandomString(withNumberOfChars numberOfChars: Int) -> String
    /// :nodoc:
    func append<T>(values: [T], toData data: inout Data, valuesType: T.Type) -> Bool
}


extension GTAssistiveTools {
    func generateRandomString(withNumberOfChars numberOfChars: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...numberOfChars).map{ _ in letters.randomElement()! })
    }
    
    
    func append<T>(values: [T], toData data: inout Data, valuesType: T.Type) -> Bool {
        var newData = Data()
        var status = true
        
        if valuesType == String.self {
            for value in values {
                guard let convertedString = (value as! String).data(using: .utf8) else { status = false; break }
                newData.append(convertedString)
            }
        } else if valuesType == Data.self {
            for value in values {
                newData.append(value as! Data)
            }
        } else {
            status = false
        }
        
        if status {
            data.append(newData)
        }
        
        return status
    }
}



// MARK: - GTKeyValueCompliantStorage Class

/**
 A custom defined type that contains the actual data definition necessary
 to make `GTKeyValueCompliant` protocol function as it is designed to.
 */
public class GTKeyValueCompliantStorage<T> {
    fileprivate var values = [String: T]()
}


// MARK: - GTKeyValueCompliant Protocol

/**
 A protocol that allows to work with key-value data in a convenient way.
 
 The protocol defines an associated type called `ValueType`, which makes it possible
 (for the protocol) to be used with any type of data. Additionally, that makes this
 protocol a reusable component that allows other entities to provide key-value pair
 based functionality hassle-free and without caring about the implementation details.
 
 A protocol extension implements the defined methods and there is no need for custom
 implementation of them.
 
 This protocol uses the `GTKeyvalueCompliantStorage` class as the custom, intermediate type
 that protects the actual data storage from direct access.
 */
public protocol GTKeyValueCompliant {
    /// An associated type that enables `GTKeyValueCompliant` protocol to be used
    /// with any type of data.
    associatedtype ValueType
    
    /// The data storage object.
    var storage: GTKeyValueCompliantStorage<ValueType> { get }
    
    /// :nodoc:
    mutating func add(value: ValueType, forKey key: String)
    /// :nodoc:
    mutating func add(multipleValues: [String: ValueType])
    /// :nodoc:
    func value(forKey key: String) -> ValueType?
    /// :nodoc:
    func getStorageValues() -> [String: ValueType]
    /// :nodoc:
    func totalItems() -> Int
}



extension GTKeyValueCompliant {
    /**
     Add the given value to storage using the given key.
     
     - Parameter value: The value to add to storage. Its type should match the `ValueType` type.
     - Parameter key: The key to pair with the given value.
     */
    public mutating func add(value: ValueType, forKey key: String) {
        storage.values[key] = value
    }
    
    
    /**
     Assign the given collection of values to storage.
     
     - Parameter multipleValues: A `[String: ValueType]` dictionary of keys and
     values to add to storage, where ValueType the data type to use.
     */
    mutating public func add(multipleValues: [String: ValueType]) {
        storage.values = multipleValues
    }
    
    
    /**
     Get the value for the given key.
     
     - Parameter key: The key for the value that is searched.
     - Returns: The found value as a ValueType, or `nil` no value is found in the
     values collection for the given key, where ValueType the data type specified
     in the `ValueType` associated type.
     
     */
    public func value(forKey key: String) -> ValueType? {
        return storage.values[key]
    }
    
    
    /**
     It returns all values currently kept in `storage` property.
    */
    public func getStorageValues() -> [String: ValueType] {
        return storage.values
    }
    
    
    /**
     It returns the total number of items in storage.
     
     - Returns: An Int value regarding the total number of values.
     */
    public func totalItems() -> Int {
        return storage.values.count
    }
}
