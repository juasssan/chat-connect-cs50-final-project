//
//  ChatSocketService.swift
//  ChatConnect
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation

enum ChatSocketEvent: Equatable {
    case history([ChatMessage])
    case message(ChatMessage)
}

protocol ChatSocketService {
    func connect(userId: Int, peerId: Int) -> AsyncThrowingStream<ChatSocketEvent, Error>
    func send(_ text: String) async throws
    func disconnect() async
}

protocol ChatWebSocketClient {
    func resume()
    func receive() async throws -> SocketMessage
    func send(string: String) async throws
    func close(code: URLSessionWebSocketTask.CloseCode)
}

enum SocketMessage {
    case string(String)
    case data(Data)
}
