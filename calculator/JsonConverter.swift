//
//  JsonConverter.swift
//  calculator
//
//  Created by Gia Duc on 09/07/2023.
//

import Foundation

struct Converter<T : Codable> {
    static func fromData (_ data : Data) throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
    
    static func toData(_ object : T) throws -> Data {
        try JSONEncoder().encode(object)
    }
}
