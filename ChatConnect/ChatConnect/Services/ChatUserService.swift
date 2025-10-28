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

struct RemoteChatUsersService: ChatUsersService {
    private let session: URLSession
    private let url: URL
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, url: URL, decoder: JSONDecoder = RemoteChatUsersService.makeDecoder()) {
        self.session = session
        self.url = url
        self.decoder = decoder
    }

    func fetchUsers() async throws -> [ChatUser] {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FetchError.requestFailed
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw FetchError.invalidStatusCode(httpResponse.statusCode)
            }

            do {
                return try decoder.decode([ChatUser].self, from: data)
            } catch {
                throw FetchError.decodingFailure
            }
        } catch let error as FetchError {
            throw error
        } catch {
            throw FetchError.requestFailed
        }
    }
}

extension RemoteChatUsersService {
    static var live: RemoteChatUsersService {
        RemoteChatUsersService(session: .shared, url: makeDefaultURL())
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    private static func makeDefaultURL() -> URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = 5001
        components.path = "/api/users"

        guard let url = components.url else {
            preconditionFailure("Failed to build chat users endpoint URL.")
        }

        return url
    }
}
