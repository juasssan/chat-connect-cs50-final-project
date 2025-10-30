//
//  ChatSocketServiceTests.swift
//  ChatConnectUnitTests
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation
import Testing
@testable import ChatConnect

struct ChatSocketServiceTests {
    private let baseURL = URL(string: "http://127.0.0.1:5001")!

    @Test func connectEmitsHistoryEvents() async throws {
        let historyJSON = """
        {
          "type": "history",
          "items": [
            {
              "from": "Sam",
              "to": "Frodo",
              "message": "Hi there!",
              "timestamp": "2024-10-31T12:34:56Z"
            }
          ]
        }
        """

        let mock = MockChatWebSocketClient(queue: [
            .success(.string(historyJSON)),
            .failure(ChatSocketServiceError.connectionClosed)
        ])

        let service = await WebSocketChatService(
            baseURL: baseURL,
            webSocketFactory: { _ in mock }
        )

        let stream = await service.connect(userId: 1, peerId: 2)
        var iterator = stream.makeAsyncIterator()

        let firstEvent = try await iterator.next()

        guard case let .history(messages) = firstEvent else {
            Issue.record("Expected history event")
            return
        }

        #expect(messages.count == 1)
        #expect(messages.first?.from == "Sam")
        #expect(messages.first?.to == "Frodo")
        #expect(messages.first?.body == "Hi there!")
        #expect(messages.first?.isAutomated == false)

        _ = try await iterator.next()
        await service.disconnect()
    }

    @Test func connectEmitsIncomingMessages() async throws {
        let messageJSON = """
        {
          "type": "message",
          "item": {
            "from": "Frodo",
            "to": "Sam",
            "message": "Where are you?",
            "timestamp": "2024-10-31T13:00:00Z",
            "auto": true
          }
        }
        """

        let mock = MockChatWebSocketClient(queue: [
            .success(.string(messageJSON)),
            .failure(ChatSocketServiceError.connectionClosed)
        ])

        let service = await WebSocketChatService(
            baseURL: baseURL,
            webSocketFactory: { _ in mock }
        )

        let stream = await service.connect(userId: 1, peerId: 2)
        var iterator = stream.makeAsyncIterator()

        let event = try await iterator.next()
        guard case let .message(message) = event else {
            Issue.record("Expected single message event")
            return
        }

        #expect(message.from == "Frodo")
        #expect(message.to == "Sam")
        #expect(message.body == "Where are you?")
        #expect(message.isAutomated == true)

        _ = try await iterator.next()
        await service.disconnect()
    }

    @Test func sendWritesToSocket() async throws {
        let mock = MockChatWebSocketClient(queue: [
            .failure(ChatSocketServiceError.connectionClosed)
        ])

        let service = await WebSocketChatService(
            baseURL: baseURL,
            webSocketFactory: { _ in mock }
        )

        let stream = await service.connect(userId: 5, peerId: 6)
        var iterator = stream.makeAsyncIterator()

        try await Task.sleep(nanoseconds: 10_000_000)

        try await service.send("Hey Sam!")

        let sent = mock.sent
        #expect(sent == ["Hey Sam!"])

        _ = try? await iterator.next()
        await service.disconnect()
    }

    @Test func invalidPayloadThrowsDecodingError() async throws {
        let invalidJSON = """
        {
          "type": "message"
        }
        """

        let mock = MockChatWebSocketClient(queue: [
            .success(.string(invalidJSON))
        ])

        let service = await WebSocketChatService(
            baseURL: baseURL,
            webSocketFactory: { _ in mock }
        )

        let stream = await service.connect(userId: 7, peerId: 8)

        await #expect(throws: ChatSocketServiceError.decodingFailed) {
            var iterator = stream.makeAsyncIterator()
            _ = try await iterator.next()
        }

        await service.disconnect()
    }
}
