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
    @State private var viewModel: ChatViewModel

    init(viewModel: ChatViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    init(
        currentUserId: Int,
        currentUserName: String,
        peer: ChatUser,
        socketService: ChatSocketService? = nil
    ) {
        let viewModel = ChatViewModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            peer: peer,
            socketService: socketService
        )
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Divider().opacity(0.1)
                messageSection
                messageInput
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(inputBackground)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
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
                Text(viewModel.peerName)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(viewModel.peerStatus)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var messageSection: some View {
        ZStack {
            messageList
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.12))
                        )
                        .padding(.bottom, 16)
                }
                .transition(.opacity)
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        messageRow(for: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .onAppear { scrollToLatest(in: proxy) }
            .onChange(of: viewModel.messages.count, initial: false) { _, _ in
                scrollToLatest(in: proxy)
            }
            .overlay {
                if viewModel.messages.isEmpty {
                    if viewModel.isLoading {
                        ProgressView("Connecting…")
                            .progressViewStyle(.circular)
                            .padding()
                    } else {
                        Text("No messages yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
        }
    }

    private func messageRow(for message: ChatMessage) -> some View {
        VStack(spacing: 4) {
            Text(timeString(for: message))
                .font(.caption2)
                .foregroundStyle(.secondary)
            messageBubble(for: message)
        }
        .frame(maxWidth: .infinity)
    }

    private func scrollToLatest(in proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }
        proxy.scrollTo(last.id, anchor: .bottom)
    }

    private func messageBubble(for message: ChatMessage) -> some View {
        let style = messageBubbleStyle(for: message)

        return HStack {
            if style.isMine { Spacer(minLength: bubbleSidePadding) }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.body)
                    .font(.body)
                    .foregroundStyle(style.text)
                    .multilineTextAlignment(.leading)
                Text(shortTimeString(for: message))
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

    private func messageBubbleStyle(for message: ChatMessage) -> (isMine: Bool, background: Color, text: Color, timestamp: Color) {
        let isMine = viewModel.ownsMessage(message)
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
            TextField("Message", text: Binding(
                get: { viewModel.draft },
                set: { viewModel.draft = $0 }
            ), axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppSystemDesign.Colors.chatInputBackground)
                )
                .foregroundStyle(.primary)

            Button {
                Task {
                    await viewModel.sendDraft()
                }
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
            .disabled(viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func timeString(for message: ChatMessage) -> String {
        Self.timeFormatter.string(from: message.timestamp)
    }

    private func shortTimeString(for message: ChatMessage) -> String {
        Self.shortTimeFormatter.string(from: message.timestamp)
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

private struct PreviewChatSocketService: ChatSocketService {
    func connect(userId: Int, peerId: Int) -> AsyncThrowingStream<ChatSocketEvent, Error> {
        AsyncThrowingStream { continuation in
            let messages = [
                ChatMessage(
                    id: UUID().uuidString,
                    from: "Samwise Gamgee",
                    to: "Frodo Baggins",
                    body: "Where are you?",
                    timestamp: Date().addingTimeInterval(-120),
                    isAutomated: false
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    from: "Frodo Baggins",
                    to: "Samwise Gamgee",
                    body: "Right behind you.",
                    timestamp: Date().addingTimeInterval(-30),
                    isAutomated: false
                )
            ]
            continuation.yield(.history(messages))
            continuation.finish()
        }
    }

    func send(_ text: String) async throws {}
    func disconnect() async {}
}

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            currentUserId: 1,
            currentUserName: "Frodo Baggins",
            peer: ChatUser(id: 2, isOnline: true, name: "Samwise Gamgee", status: "Gardening"),
            socketService: PreviewChatSocketService()
        )
    )
    .preferredColorScheme(.dark)
}

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            currentUserId: 1,
            currentUserName: "Frodo Baggins",
            peer: ChatUser(id: 2, isOnline: true, name: "Samwise Gamgee", status: "Gardening"),
            socketService: PreviewChatSocketService()
        )
    )
    .preferredColorScheme(.light)
}
