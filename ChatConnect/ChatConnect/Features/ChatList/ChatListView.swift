//
//  ChatListView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI

struct ChatListView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ChatItemView()
                    ChatItemView()
                    ChatItemView()
                }
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatListView()
}
