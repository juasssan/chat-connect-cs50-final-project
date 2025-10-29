//
//  AppSystemDesign.swift
//  ChatConnect
//
//  Created by Julio Cesar on 28/10/25.
//

import SwiftUI

enum AppSystemDesign {
    enum Colors {
        static let chatListBackgroundLight = Color(.systemBlue).opacity(0.1)
        static let chatListBackgroundDark = Color(.systemBlue).opacity(0.2)
        static let chatListErrorIcon = Color.orange
        static let chatListSecondaryText = Color.secondary
        static let chatItemStroke = Color(.quaternarySystemFill)
        static let chatItemFillLight = Color(.tertiarySystemFill)
        static let chatItemFillDark = Color(.tertiarySystemFill)
        static let chatItemAvatar = Color.blue
        static let chatItemStatusOnline = Color.green
        static let chatItemStatusOffline = Color.secondary
        static let chatBubbleStroke = chatItemStroke
        static let chatBubbleMineBackground = chatItemFillDark
        static let chatBubblePeerBackground = chatItemFillLight
        static let chatBubbleMineText = Color.primary
        static let chatBubblePeerText = Color.primary
        static let chatBubbleMineTimestamp = Color.secondary
        static let chatBubblePeerTimestamp = Color.secondary
        static let chatInputBackground = chatItemFillLight
        static let chatSendButtonBackground = chatItemAvatar
        static let chatSendButtonIcon = Color.white
    }
}
