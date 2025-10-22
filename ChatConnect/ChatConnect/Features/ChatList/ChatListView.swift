//
//  ChatListView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI

struct ChatListView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .dark {
                    Color(.systemBlue)
                        .opacity(0.2)
                        .ignoresSafeArea()
                } else {
                    Color(.systemBlue)
                        .opacity(0.1)
                        .ignoresSafeArea()
                }

                ScrollView {
                    LazyVStack {
                        Divider()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                        ChatItemView()
                    }
                }
                .navigationTitle("Chats")
                .font(.largeTitle)
            }
        }
    }
}

#Preview {
    ChatListView().preferredColorScheme(.light)
}

#Preview {
    ChatListView().preferredColorScheme(.dark)
}
