//
//  MockChatSocketService.swift
//  ChatConnectUnitTests
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation
@testable import ChatConnect

final class MockChatSocketService: ChatSocketService {
    private(set) var connectCalls: [(userId: Int, peerId: Int)] = []
    private(set) var sentMessages: [String] = []
    private(set) var disconnectCallCount = 0

    var sendError: Error?
    private var continuation: AsyncThrowingStream<ChatSocketEvent, Error>.Continuation?
    private var bufferedEvents: [ChatSocketEvent] = []

    func connect(userId: Int, peerId: Int) -> AsyncThrowingStream<ChatSocketEvent, Error> {
        connectCalls.append((userId, peerId))

        return AsyncThrowingStream { continuation in
            self.continuation = continuation
            for event in self.bufferedEvents {
                continuation.yield(event)
            }
            self.bufferedEvents.removeAll()
        }
    }

    func send(_ text: String) async throws {
        if let sendError {
            throw sendError
        }
        sentMessages.append(text)
    }

    func disconnect() async {
        disconnectCallCount += 1
    }

    func emit(_ event: ChatSocketEvent) {
        if let continuation {
            continuation.yield(event)
        } else {
            bufferedEvents.append(event)
        }
    }

    func finish(error: Error? = nil) {
        if let error {
            continuation?.finish(throwing: error)
        } else {
            continuation?.finish()
        }
    }
}
