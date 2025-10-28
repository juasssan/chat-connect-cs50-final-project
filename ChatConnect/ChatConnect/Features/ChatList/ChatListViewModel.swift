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

    private let service: ChatUsersService

    init(users: [ChatUser] = [],
         service: ChatUsersService? = nil) {
        self.service = service ?? RemoteChatUsersService.live
        self.users = users
    }

    func fetchUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedUsers = try await service.fetchUsers()
            self.users = fetchedUsers
        } catch let error as FetchError {
            self.users = []
            errorMessage = error.reason
        } catch {
            self.users = []
            errorMessage = (error as? FetchError)?.reason ?? FetchError.requestFailed.reason
        }
    }
}
