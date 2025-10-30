//
//  ChatViewModel.swift
//  ChatConnect
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation
import Observation

@Observable
final class ChatViewModel {
    let peerName: String
    let peerStatus: String
    let currentUserName: String

    private(set) var messages: [ChatMessage]
    private(set) var isLoading: Bool
    private(set) var errorMessage: String?
    var draft: String = ""

    private let currentUserId: Int
    private let peerId: Int
    private let socketService: ChatSocketService
    private var streamTask: Task<Void, Never>?
    private var didRequestDisconnect = false

    init(
        currentUserId: Int,
        currentUserName: String,
        peer: ChatUser,
        socketService: ChatSocketService? = nil,
        initialMessages: [ChatMessage] = []
    ) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.peerId = peer.id
        self.peerName = peer.name
        self.peerStatus = peer.status ?? "No status yet."
        self.socketService = socketService ?? WebSocketChatService.live
        self.messages = initialMessages
        self.isLoading = initialMessages.isEmpty
        self.errorMessage = nil
    }

    func start() {
        guard streamTask == nil else { return }
        errorMessage = nil

        if messages.isEmpty {
            isLoading = true
        }

        let stream = socketService.connect(userId: currentUserId, peerId: peerId)
        didRequestDisconnect = false

        streamTask = Task { [weak self] in
            guard let self else { return }
            await self.listen(to: stream)
        }
    }

    func stop() {
        streamTask?.cancel()
        streamTask = nil
        isLoading = false
        requestDisconnectIfNeeded()
    }

    func sendDraft() async {
        let originalDraft = draft
        let trimmed = originalDraft.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            draft = ""
            return
        }

        draft = ""
        errorMessage = nil

        do {
            try await socketService.send(trimmed)
        } catch {
            draft = originalDraft
            errorMessage = describe(error)
            #if DEBUG
            print("[ChatViewModel] sendDraft error:", error)
            #endif
        }
    }

    deinit {
        stop()
    }

    private func listen(to stream: AsyncThrowingStream<ChatSocketEvent, Error>) async {
        defer {
            Task { @MainActor in
                self.streamTask = nil
                self.isLoading = false
                self.requestDisconnectIfNeeded()
            }
        }

        do {
            for try await event in stream {
                await MainActor.run {
                    self.handle(event)
                }
            }
        } catch is CancellationError {
            // Intentional cancellation; nothing to surface.
        } catch {
            if Self.isConnectionClosedError(error) { return }
            await MainActor.run {
                self.errorMessage = describe(error)
            }
            #if DEBUG
            print("[ChatViewModel] stream error:", error)
            #endif
        }
    }

    private func requestDisconnectIfNeeded() {
        guard !didRequestDisconnect else { return }
        didRequestDisconnect = true
        let service = socketService
        Task {
            await service.disconnect()
        }
    }

    private func handle(_ event: ChatSocketEvent) {
        switch event {
        case .history(let history):
            messages = history
            isLoading = false
        case .message(let message):
            messages.append(message)
        }
    }

    private func describe(_ error: Error) -> String {
        if let socketError = error as? ChatSocketServiceError {
            switch socketError {
            case .notConnected:
                return "Not connected to chat."
            case .decodingFailed:
                return "Could not read messages."
            case .invalidMessage:
                return "Received invalid message."
            case .connectionClosed:
                return "Connection closed."
            }
        }
        return "Something went wrong."
    }

    func ownsMessage(_ message: ChatMessage) -> Bool {
        message.from == currentUserName || message.from == String(currentUserId)
    }

    private static func isConnectionClosedError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return urlError.code == .networkConnectionLost || urlError.code == .cannotConnectToHost
        }
        let nsError = error as NSError
        return nsError.domain == NSPOSIXErrorDomain && nsError.code == 57
    }
}
