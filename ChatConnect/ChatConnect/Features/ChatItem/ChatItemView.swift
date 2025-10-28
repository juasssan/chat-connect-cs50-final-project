//
//  ChatView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI

struct ChatItemView: View {
    @Environment(\.colorScheme) var colorScheme
    let user: ChatUser

    private var statusText: String {
        user.isOnline ? "online" : "offline"
    }

    private var statusColor: Color {
        user.isOnline ? .green : .secondary
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    colorScheme == .dark ? .quinary : .quinary,
                    lineWidth: 4
                )
                .fill(colorScheme == .dark ? .quaternary : .quinary)
                .frame(height: 100)
            HStack(alignment: .top) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 60)
                        Text(user.initials)
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                            .fontWeight(.bold)
                    }
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .lineLimit(1)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(user.status ?? "No status yet.")
                            .lineLimit(1)
                            .font(.title3)
                            .fontDesign(.rounded)
                    }
                }
                .frame(maxHeight: 80)
                .padding(.leading)
                Spacer()
                Text(statusText)
                    .font(.callout)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                    .foregroundStyle(statusColor)
                    .padding(.top, 12)
                    .padding(.trailing, 16)
                    .layoutPriority(1)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ChatItemView(
        user: ChatUser(id: 1, isOnline: true, name: "Mr. Pickles", status: "Cooking 👊🔥")
    )
    .preferredColorScheme(.dark)
    ChatItemView(
        user: ChatUser(id: 1, isOnline: true, name: "Bee", status: "🐝")
    )
    .preferredColorScheme(.dark)
    ChatItemView(
        user: ChatUser(id: 1, isOnline: true, name: "Mr. Leo The Lion", status: "roar roar roar roar roar")
    )
    .preferredColorScheme(.dark)
}

#Preview {
    ChatItemView(
        user: ChatUser(id: 2, isOnline: false, name: "Morty Smith", status: "Doing homework")
    )
    .preferredColorScheme(.light)
}
