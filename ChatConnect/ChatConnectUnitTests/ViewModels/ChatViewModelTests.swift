//
//  ChatViewModelTests.swift
//  ChatConnectUnitTests
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation
import Testing
@testable import ChatConnect

@MainActor
struct ChatViewModelTests {
    private let peer = ChatUser(id: 2, isOnline: true, name: "Samwise Gamgee", status: "Gardening")
    private let currentUserName = "Frodo Baggins"
    private let currentUserId = 1

    @Test func startLoadsHistoryAndAppendsMessages() async throws {
        let socket = MockChatSocketService()
        let viewModel = ChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            peer: peer,
            socketService: socket
        )

        viewModel.start()

        #expect(socket.connectCalls.count == 1)
        #expect(socket.connectCalls.first?.userId == currentUserId)
        #expect(socket.connectCalls.first?.peerId == peer.id)

        let history = [
            ChatMessage(
                id: "1",
                from: peer.name,
                to: currentUserName,
                body: "Hi!",
                timestamp: Date(),
                isAutomated: false
            )
        ]

        socket.emit(.history(history))
        try await waitForCondition {
            viewModel.messages == history && viewModel.isLoading == false
        }

        #expect(viewModel.messages == history)
        #expect(viewModel.isLoading == false)

        let newMessage = ChatMessage(
            id: "2",
            from: currentUserName,
            to: peer.name,
            body: "Hey Sam!",
            timestamp: Date().addingTimeInterval(10),
            isAutomated: false
        )

        socket.emit(.message(newMessage))
        try await waitForCondition {
            viewModel.messages.last == newMessage
        }

        #expect(viewModel.messages.last == newMessage)

        socket.finish()
        viewModel.stop()
    }

    @Test func sendDraftTrimsAndClearsInput() async throws {
        let socket = MockChatSocketService()
        let viewModel = ChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            peer: peer,
            socketService: socket
        )

        viewModel.draft = "  Hello Sam  "
        await viewModel.sendDraft()

        #expect(socket.sentMessages == ["Hello Sam"])
        #expect(viewModel.draft.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func sendDraftRestoresInputOnFailure() async throws {
        let socket = MockChatSocketService()
        socket.sendError = ChatSocketServiceError.notConnected

        let viewModel = ChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            peer: peer,
            socketService: socket
        )

        viewModel.draft = "Test"
        await viewModel.sendDraft()

        #expect(socket.sentMessages.isEmpty)
        #expect(viewModel.draft == "Test")
        #expect(viewModel.errorMessage == "Not connected to chat.")
    }

    @Test func stopDisconnectsSocket() async throws {
        let socket = MockChatSocketService()
        let viewModel = ChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            peer: peer,
            socketService: socket
        )

        viewModel.start()
        await Task.yield()

        viewModel.stop()
        await Task.yield()

        #expect(socket.disconnectCallCount == 1)
    }

    private func waitForCondition(
        timeout: UInt64 = 200_000_000,
        interval: UInt64 = 10_000_000,
        predicate: @escaping () -> Bool
    ) async throws {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeout
        while DispatchTime.now().uptimeNanoseconds < deadline {
            let satisfied = await MainActor.run { predicate() }
            if satisfied { return }
            try await Task.sleep(nanoseconds: interval)
        }
        Issue.record("Condition not satisfied before timeout")
    }
}
