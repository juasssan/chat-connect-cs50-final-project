//
//  MockChatWebSocketClient.swift
//  ChatConnectUnitTests
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation
@testable import ChatConnect

class MockChatWebSocketClient: ChatWebSocketClient {
    private var queue: [Result<SocketMessage, Error>]
    private(set) var sent: [String] = []
    private(set) var didResume = false
    private(set) var closedCodes: [URLSessionWebSocketTask.CloseCode] = []

    init(queue: [Result<SocketMessage, Error>]) {
        self.queue = queue
    }

    func resume() {
        didResume = true
    }

    func receive() async throws -> SocketMessage {
        guard !queue.isEmpty else {
            throw ChatSocketServiceError.connectionClosed
        }
        let result = queue.removeFirst()
        switch result {
        case .success(let message):
            return message
        case .failure(let error):
            throw error
        }
    }

    func send(string: String) async throws {
        sent.append(string)
    }

    func close(code: URLSessionWebSocketTask.CloseCode) {
        closedCodes.append(code)
    }
}
