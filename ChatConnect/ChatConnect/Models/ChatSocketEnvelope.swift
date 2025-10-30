//
//  ChatSocketEnvelope.swift
//  ChatConnect
//
//  Created by Julio Cesar on 29/10/25.
//

import Foundation

struct ChatSocketEnvelope: Decodable {
    enum PayloadType: String, Decodable {
        case history
        case message
    }

    struct MessagePayload: Decodable {
        let from: String
        let to: String
        let message: String
        let timestamp: String
        let auto: Bool?

        func makeMessage(using formatter: ISO8601DateFormatter) throws -> ChatMessage {
            guard let date = formatter.date(from: timestamp) ?? MessagePayload.fallbackFormatter.date(from: timestamp) else {
                throw ChatSocketServiceError.decodingFailed
            }

            return ChatMessage(
                id: "\(timestamp)|\(from)|\(message)",
                from: from,
                to: to,
                body: message,
                timestamp: date,
                isAutomated: auto ?? false
            )
        }

        private static let fallbackFormatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            return formatter
        }()
    }

    let type: PayloadType
    let items: [MessagePayload]?
    let item: MessagePayload?

    func event(using formatter: ISO8601DateFormatter) throws -> ChatSocketEvent {
        switch type {
        case .history:
            guard let items else {
                throw ChatSocketServiceError.decodingFailed
            }
            let history = try items.map { try $0.makeMessage(using: formatter) }
            return .history(history)
        case .message:
            guard let item else {
                throw ChatSocketServiceError.decodingFailed
            }
            return .message(try item.makeMessage(using: formatter))
        }
    }
}
