//
//  ChatListViewModel.swift
//  ChatConnect
//
//  Created by Julio Cesar on 28/10/25.
//

import Observation

@Observable
final class ChatListViewModel {
    private(set) var users: [ChatUser]
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var currentUserId: Int
    private(set) var currentUserName: String

    private let service: ChatUsersService
    private let hasExplicitCurrentUser: Bool

    init(users: [ChatUser] = [],
         currentUserId: Int = 0,
         currentUserName: String = "You",
         service: ChatUsersService? = nil) {
        self.service = service ?? RemoteChatUsersService.live
        self.users = users
        self.hasExplicitCurrentUser = currentUserId > 0
        if hasExplicitCurrentUser {
            self.currentUserId = currentUserId
            self.currentUserName = currentUserName.isEmpty ? "You" : currentUserName
        } else {
            self.currentUserId = ChatListViewModel.defaultCurrentUserId
            self.currentUserName = currentUserName.isEmpty ? "You" : currentUserName
        }
        if !hasExplicitCurrentUser && !users.isEmpty {
            self.users = configureCurrentUserIfNeeded(from: users)
        }
    }

    func fetchUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedUsers = try await service.fetchUsers()
            self.users = configureCurrentUserIfNeeded(from: fetchedUsers)
        } catch let error as FetchError {
            self.users = []
            errorMessage = error.reason
        } catch {
            self.users = []
            errorMessage = (error as? FetchError)?.reason ?? FetchError.requestFailed.reason
        }
    }

    private func configureCurrentUserIfNeeded(from fetchedUsers: [ChatUser]) -> [ChatUser] {
        guard !hasExplicitCurrentUser else {
            return fetchedUsers
        }
        if currentUserName.isEmpty {
            currentUserName = "You"
        }
        return fetchedUsers
    }

    private static let defaultCurrentUserId: Int = 99
}
