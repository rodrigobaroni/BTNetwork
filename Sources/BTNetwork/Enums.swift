//
//  Enums.swift
//  BTNetwork
//
//  Created by Rodrigo Baroni on 16/08/21.
//

import Foundation

public enum ResultError: Error {
    case undecodable
    case invalidToken
    case internalServerError
    case badRequest
    case invalidInfo(String)
    case unauthorized
    case conflict(String)
    case notFound(String)
    case custom(String)
    case empty
}
