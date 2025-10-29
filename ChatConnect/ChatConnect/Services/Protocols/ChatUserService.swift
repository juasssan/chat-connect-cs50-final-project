//
//  ChatUserService.swift
//  ChatConnect
//
//  Created by Julio Cesar on 28/10/25.
//

import Foundation

protocol ChatUsersService {
    func fetchUsers() async throws -> [ChatUser]
}
