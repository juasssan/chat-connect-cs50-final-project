//
//  URLSessionChatWebSocketClient.swift
//  ChatConnect
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation

final class URLSessionChatWebSocketClient: ChatWebSocketClient {
    private let task: URLSessionWebSocketTask

    init(task: URLSessionWebSocketTask) {
        self.task = task
    }

    func resume() {
        task.resume()
    }

    func receive() async throws -> SocketMessage {
        let message = try await task.receive()
        switch message {
        case .string(let text):
            return .string(text)
        case .data(let data):
            return .data(data)
        @unknown default:
            throw ChatSocketServiceError.invalidMessage
        }
    }

    func send(string: String) async throws {
        try await task.send(.string(string))
    }

    func close(code: URLSessionWebSocketTask.CloseCode) {
        task.cancel(with: code, reason: nil)
    }
}

