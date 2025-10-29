//
//  ChatListViewModelTests.swift
//  ChatConnectUnitTests
//
//  Created by Julio Cesar on 28/10/25.
//

import Foundation
import Testing
@testable import ChatConnect

actor StubChatUserService: ChatUsersService {
    enum StubError: Error {
        case sample
    }

    var result: Result<[ChatUser], Error>

    init(result: Result<[ChatUser], Error>) {
        self.result = result
    }

    func fetchUsers() async throws -> [ChatUser] {
        try result.get()
    }
}

@MainActor
struct ChatListViewModelTests {
    @Test func fetchUsersPopulatesList() async throws {
        let expectedUsers = [
            ChatUser(id: 1, isOnline: true, name: "Frodo Baggins", status: "lost again"),
            ChatUser(id: 2, isOnline: false, name: "Samwise Gamgee", status: nil)
        ]

        let service = StubChatUserService(result: .success(expectedUsers))
        let viewModel = ChatListViewModel(service: service)

        await viewModel.fetchUsers()

        #expect(viewModel.users == expectedUsers)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func fetchUsersHandlesServiceErrors() async throws {
        let service = StubChatUserService(result: .failure(StubChatUserService.StubError.sample))
        let viewModel = ChatListViewModel(service: service)

        await viewModel.fetchUsers()

        #expect(viewModel.users.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
}
