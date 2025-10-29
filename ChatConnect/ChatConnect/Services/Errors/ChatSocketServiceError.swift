//
//  ChatSocketServiceError.swift
//  ChatConnect
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation

enum ChatSocketServiceError: Error, Equatable {
    case notConnected
    case decodingFailed
    case invalidMessage
    case connectionClosed
}
