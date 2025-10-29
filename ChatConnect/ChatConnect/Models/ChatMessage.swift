//
//  ChatMessage.swift
//  ChatConnect
//
//  Created by Julio Cesar on 28/10/25.
//

import Foundation

struct ChatMessage: Equatable, Identifiable {
    let id: String
    let from: String
    let to: String
    let body: String
    let timestamp: Date
    let isAutomated: Bool

    init(id: String, from: String, to: String, body: String, timestamp: Date, isAutomated: Bool) {
        self.id = id
        self.from = from
        self.to = to
        self.body = body
        self.timestamp = timestamp
        self.isAutomated = isAutomated
    }
}
