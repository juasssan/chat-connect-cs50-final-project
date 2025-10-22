//
//  ChatView.swift
//  ChatConnect
//
//  Created by Julio Cesar on 22/10/25.
//

import SwiftUI


struct ChatView: View {

    var body: some View {
        HStack() {
            Text("NM")
            VStack(alignment: .leading) {
                Text("Name Name")
                Text("Current status 👊")
            }.padding()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    ChatView()
}
