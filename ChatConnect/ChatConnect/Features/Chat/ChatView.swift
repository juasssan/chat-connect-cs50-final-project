//
//  ChatView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""

    let peerName: String
    let peerStatus: String
    let currentUserName: String
    let messages: [MockMessage]

    init(
        peerName: String = "Tom Bombadil",
        peerStatus: String = "Chilling",
        currentUserName: String = "You",
        messages: [MockMessage] = MockMessage.sampleConversation
    ) {
        self.peerName = peerName
        self.peerStatus = peerStatus
        self.currentUserName = currentUserName
        self.messages = messages
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Divider().opacity(0.1)
                messageList
                messageInput
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(inputBackground)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var isDarkMode: Bool { colorScheme == .dark }

    private var backgroundColor: Color {
        isDarkMode ? AppSystemDesign.Colors.chatListBackgroundDark : AppSystemDesign.Colors.chatListBackgroundLight
    }

    private var inputBackground: Color {
        isDarkMode ? Color.white.opacity(0.02) : Color.blue.opacity(0.06)
    }

    private let bubbleSidePadding: CGFloat = 40

    private var header: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        colorScheme == .dark ?
                                        Color.primary.opacity(0.07) : Color.primary.opacity(0.35))
                            )
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(peerName)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(peerStatus)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        messageRow(for: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .onAppear { scrollToLatest(in: proxy) }
        }
    }

    private func messageRow(for message: MockMessage) -> some View {
        VStack(spacing: 4) {
            Text(message.timeString)
                .font(.caption2)
                .foregroundStyle(.secondary)
            messageBubble(for: message)
        }
        .frame(maxWidth: .infinity)
    }

    private func scrollToLatest(in proxy: ScrollViewProxy) {
        guard let last = messages.last else { return }
        proxy.scrollTo(last.id, anchor: .bottom)
    }

    private func messageBubble(for message: MockMessage) -> some View {
        let style = messageBubbleStyle(for: message)

        return HStack {
            if style.isMine { Spacer(minLength: bubbleSidePadding) }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(style.text)
                    .multilineTextAlignment(.leading)
                Text(message.timeShortString)
                    .font(.caption2)
                    .foregroundStyle(style.timestamp)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppSystemDesign.Colors.chatBubbleStroke, lineWidth: 4)
                    .fill(style.background)
            )
            if !style.isMine { Spacer(minLength: bubbleSidePadding) }
        }
        .frame(maxWidth: .infinity, alignment: style.isMine ? .trailing : .leading)
    }

    private func messageBubbleStyle(for message: MockMessage) -> (isMine: Bool, background: Color, text: Color, timestamp: Color) {
        let isMine = message.author == currentUserName
        let background = isMine
            ? AppSystemDesign.Colors.chatBubbleMineBackground
            : AppSystemDesign.Colors.chatBubblePeerBackground
        let text = isMine
            ? AppSystemDesign.Colors.chatBubbleMineText
            : AppSystemDesign.Colors.chatBubblePeerText
        let timestamp = isMine
            ? AppSystemDesign.Colors.chatBubbleMineTimestamp
            : AppSystemDesign.Colors.chatBubblePeerTimestamp
        return (isMine, background, text, timestamp)
    }

    private var messageInput: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $draft, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppSystemDesign.Colors.chatInputBackground)
                )
                .foregroundStyle(.primary)

            Button {
                // TODO: send message to backend and refresh the items in the screen
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppSystemDesign.Colors.chatSendButtonIcon)
                    .padding(12)
                    .background(
                        Circle().fill(AppSystemDesign.Colors.chatSendButtonBackground)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

struct MockMessage: Identifiable {
    let id: UUID = .init()
    let author: String
    let text: String
    let time: Date

    var timeString: String {
        Self.timeFormatter.string(from: time)
    }

    var timeShortString: String {
        Self.shortTimeFormatter.string(from: time)
    }

    static var sampleConversation: [MockMessage] {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date()).addingTimeInterval(60 * 60 * 21 + 30 * 60) // 9:30 PM
        return [
            MockMessage(author: "You", text: "I'm good, how about", time: base),
            MockMessage(author: "Tom Bombadil", text: "I'm doing great, thanks!", time: base.addingTimeInterval(120)),
            MockMessage(author: "You", text: "I'm doing great thanks!", time: base.addingTimeInterval(180)),
            MockMessage(author: "J. R. R. Tolkien", text: "Glad to hear that!", time: base.addingTimeInterval(240))
        ]
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }()
}

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}

#Preview {
    ChatView()
        .preferredColorScheme(.light)
}
