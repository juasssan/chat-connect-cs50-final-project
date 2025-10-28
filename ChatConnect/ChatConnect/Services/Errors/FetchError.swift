//
//  FetchError.swift
//  ChatConnect
//
//  Created by Julio Cesar on 28/10/25.
//

import Foundation

enum FetchError: Error {
    case invalidStatusCode(Int)
    case decodingFailure
    case requestFailed

    var reason: String {
        switch self {
        case .invalidStatusCode:
            return "The server returned an unexpected response."
        case .decodingFailure:
            return "We couldn't load the chat list."
        case .requestFailed:
            return "We couldn't contact the server."
        }
    }
}
