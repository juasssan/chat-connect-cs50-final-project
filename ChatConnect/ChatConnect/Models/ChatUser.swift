//
//  ChatUser.swift
//  ChatConnect
//
//  Created by Julio Cesar on 28/10/25.
//

import Foundation

struct ChatUser: Codable, Equatable, Identifiable {
    let id: Int
    let isOnline: Bool
    let name: String
    let status: String?

    var initials: String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).map { $0.prefix(1).uppercased() }.joined()
        return initials.isEmpty ? "??" : initials
    }
}
