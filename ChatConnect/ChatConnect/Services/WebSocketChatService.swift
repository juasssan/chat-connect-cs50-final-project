//
//  WebSocketChatService.swift
//  ChatConnect
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation

final class WebSocketChatService: ChatSocketService {
    private let baseURL: URL
    private let webSocketFactory: (URL) -> ChatWebSocketClient
    private let decoder: JSONDecoder
    private let isoFormatter: ISO8601DateFormatter

    private var client: ChatWebSocketClient?
    private var receiveTask: Task<Void, Never>?

    init(
        baseURL: URL,
        webSocketFactory: @escaping (URL) -> ChatWebSocketClient = { url in
            let session = URLSession(configuration: .default)
            let task = session.webSocketTask(with: url)
            return URLSessionChatWebSocketClient(task: task)
        }
    ) {
        self.baseURL = baseURL
        self.webSocketFactory = webSocketFactory
        self.decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.isoFormatter = formatter
    }

    func connect(userId: Int, peerId: Int) -> AsyncThrowingStream<ChatSocketEvent, Error> {
        let client = prepareClient(userId: userId, peerId: peerId)

        return AsyncThrowingStream { [weak self] continuation in
            guard let self else { return }
            continuation.onTermination = { [weak self] termination in
                guard case .cancelled = termination else { return }
                Task { await self?.disconnect() }
            }
            self.startListening(client: client, continuation: continuation)
        }
    }

    func send(_ text: String) async throws {
        guard let client else {
            throw ChatSocketServiceError.notConnected
        }
        try await client.send(string: text)
    }

    func disconnect() async {
        receiveTask?.cancel()
        receiveTask = nil
        client?.close(code: .normalClosure)
        client = nil
    }

    private func prepareClient(userId: Int, peerId: Int) -> ChatWebSocketClient {
        let client = webSocketFactory(socketURL(userId: userId, peerId: peerId))
        self.client = client
        client.resume()
        return client
    }

    private func startListening(
        client: ChatWebSocketClient,
        continuation: AsyncThrowingStream<ChatSocketEvent, Error>.Continuation
    ) {
        receiveTask?.cancel()
        receiveTask = Task { [weak self] in
            guard let self else { return }
            defer { self.receiveTask = nil }
            do {
                while !Task.isCancelled {
                    let message = try await client.receive()
                    continuation.yield(try self.event(from: message))
                }
                continuation.finish()
            } catch is CancellationError {
                continuation.finish()
            } catch {
                if Self.isConnectionClosedError(error) {
                    continuation.finish()
                } else {
                    #if DEBUG
                    print("[WebSocketChatService] receive loop error:", error)
                    #endif
                    handleError(error, continuation: continuation)
                }
            }
        }
    }

    private func handleError(
        _ error: Error,
        continuation: AsyncThrowingStream<ChatSocketEvent, Error>.Continuation
    ) {
        #if DEBUG
        print("[WebSocketChatService] handling error:", error)
        #endif
        if (error as? ChatSocketServiceError) == .connectionClosed || Self.isConnectionClosedError(error) {
            continuation.finish()
        } else {
            continuation.finish(throwing: error)
        }
    }

    private func socketURL(userId: Int, peerId: Int) -> URL {
        var components = URLComponents()
        let isSecure = baseURL.scheme?.lowercased() == "https"
        components.scheme = isSecure ? "wss" : "ws"
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = "/ws/chat"
        components.queryItems = [
            URLQueryItem(name: "userId", value: "\(userId)"),
            URLQueryItem(name: "withId", value: "\(peerId)")
        ]

        guard let url = components.url else {
            preconditionFailure("Failed to build chat socket URL.")
        }

        return url
    }

    private func event(from message: SocketMessage) throws -> ChatSocketEvent {
        try decodeEvent(from: data(from: message))
    }

    private func data(from message: SocketMessage) throws -> Data {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8) else {
                throw ChatSocketServiceError.decodingFailed
            }
            return data
        case .data(let data):
            return data
        }
    }

    private func decodeEvent(from data: Data) throws -> ChatSocketEvent {
        do {
            return try decoder
                .decode(ChatSocketEnvelope.self, from: data)
                .event(using: isoFormatter)
        } catch let error as ChatSocketServiceError {
            #if DEBUG
            print("[WebSocketChatService] decode error:", error)
            #endif
            throw error
        } catch {
            #if DEBUG
            print("[WebSocketChatService] unexpected decode error:", error)
            #endif
            throw ChatSocketServiceError.decodingFailed
        }
    }

    private static func isConnectionClosedError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            return urlError.code == .networkConnectionLost || urlError.code == .cannotConnectToHost
        }
        let nsError = error as NSError
        return nsError.domain == NSPOSIXErrorDomain && nsError.code == 57
    }
}

extension WebSocketChatService {
    static var live: WebSocketChatService {
        WebSocketChatService(baseURL: makeDefaultBaseURL())
    }

    private static func makeDefaultBaseURL() -> URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = 5001

        guard let url = components.url else {
            preconditionFailure("Failed to build chat socket base URL.")
        }

        return url
    }
}
