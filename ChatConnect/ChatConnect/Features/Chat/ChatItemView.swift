//
//  ChatView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI


struct ChatItemView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    colorScheme == .dark ? .quinary : .quinary,
                    lineWidth: 4
                )
                .fill(colorScheme == .dark ? .quaternary : .quinary)
                .frame(height: 100)
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 70)
                    Text("NM")
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                        .fontWeight(.bold)
                }
                VStack(alignment: .leading) {
                    Text("Mr. Pickles")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Cooking 👊🔥")
                        .font(.title2)
                        .fontDesign(.rounded)
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ChatItemView().preferredColorScheme(.dark)
}

#Preview {
    ChatItemView().preferredColorScheme(.light)
}
