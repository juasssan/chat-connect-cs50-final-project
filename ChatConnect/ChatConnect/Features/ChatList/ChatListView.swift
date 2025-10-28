//
//  ChatListView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI

struct ChatListView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel: ChatListViewModel

    init(viewModel: ChatListViewModel = ChatListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                content.padding(.horizontal, 8)
            }
            .navigationTitle("Chats")
            .font(.largeTitle)
        }
        .task {
            await viewModel.fetchUsers()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            ProgressView("Loading chats…").progressViewStyle(.circular)

        } else if let errorMessage = viewModel.errorMessage, viewModel.users.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text(errorMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else if viewModel.users.isEmpty {
            Text("No chats yet.")
                .font(.headline)
                .foregroundStyle(.secondary)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    Divider()
                    ForEach(viewModel.users) { user in
                        ChatItemView(user: user)
                    }
                }
                .padding(.vertical)
            }
        }
    }

    private var backgroundColor: some View {
        Group {
            if colorScheme == .dark {
                Color(.systemBlue)
                    .opacity(0.2)
            } else {
                Color(.systemBlue)
                    .opacity(0.1)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ChatListView(
        viewModel: ChatListViewModel(
            users: [
                ChatUser(id: 1, isOnline: true, name: "Frodo Baggins", status: "Questing"),
                ChatUser(id: 2, isOnline: false, name: "Samwise Gamgee", status: "Gardening")
            ],
            service: PreviewChatUsersService(
                users: [
                    ChatUser(id: 1, isOnline: true, name: "Frodo Baggins", status: "Questing"),
                    ChatUser(id: 2, isOnline: false, name: "Samwise Gamgee", status: "Gardening")
                ]
            )
        )
    )
    .preferredColorScheme(.light)
}

#Preview {
    ChatListView(
        viewModel: ChatListViewModel(
            users: [
                ChatUser(id: 3, isOnline: true, name: "Gandalf the Grey", status: "Arriving precisely when he means to")
            ],
            service: PreviewChatUsersService(
                users: [
                    ChatUser(id: 3, isOnline: true, name: "Gandalf the Grey", status: "Arriving precisely when he means to")
                ]
            )
        )
    )
    .preferredColorScheme(.dark)
}

private struct PreviewChatUsersService: ChatUsersService {
    let users: [ChatUser]

    func fetchUsers() async throws -> [ChatUser] {
        users
    }
}
