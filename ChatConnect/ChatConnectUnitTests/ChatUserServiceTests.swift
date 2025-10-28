//
//  ChatUserServiceTests.swift
//  ChatConnectUnitTests
//
//  Created by Julio Cesar on 28/10/25.
//

import Foundation
import Testing
@testable import ChatConnect

struct ChatUserServiceTests {
    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func makeURL() -> URL {
        URL(string: "http://127.0.0.1:5001/api/users")!
    }

    @Test func fetchUsersReturnsDecodedUsers() async throws {
        let sampleJSON = """
        [
          { "id": 1, "isOnline": true, "name": "Frodo Baggins", "status": "lost again" },
          { "id": 2, "isOnline": false, "name": "Samwise Gamgee", "status": null }
        ]
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, sampleJSON)
        }
        defer { MockURLProtocol.requestHandler = nil }

        let service = await RemoteChatUsersService(session: makeSession(), url: makeURL())
        let users = try await service.fetchUsers()

        #expect(users.count == 2)
        #expect(users.first?.name == "Frodo Baggins")
    }

    @Test func fetchUsersThrowsOnBadStatusCode() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        defer { MockURLProtocol.requestHandler = nil }

        let service = await RemoteChatUsersService(session: makeSession(), url: makeURL())

        await #expect(throws: Error.self) {
            _ = try await service.fetchUsers()
        }
    }
}
