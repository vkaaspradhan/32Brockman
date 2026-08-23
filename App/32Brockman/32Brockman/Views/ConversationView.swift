import SwiftUI
import SwiftData

struct ConversationView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [Message]
    @State private var draft = ""
    private let conversation: Conversation

    init(conversation: Conversation) {
        self.conversation = conversation
        let cid = conversation.id
        let predicate = #Predicate<Message> { $0.conversationID == cid }
        _messages = Query(filter: predicate, sort: \Message.createdAt)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { msg in
                            MessageBubble(msg: msg, isMine: msg.senderID == auth.currentUser?.id)
                                .id(msg.id)
                        }
                    }
                    .padding(12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }

            Divider()
            HStack(spacing: 8) {
                TextField("Message", text: $draft)
                    .textFieldStyle(.roundedBorder)
                Button { send() } label: { Image(systemName: "arrow.up.circle.fill").font(.title2) }
                    .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .navigationTitle("Chat")
        .onAppear { markRead() }
    }

    private func send() {
        guard let me = auth.currentUser else { return }
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let msg = Message(conversationID: conversation.id, senderID: me.id, text: text)
        modelContext.insert(msg)
        conversation.lastMessageText = text
        conversation.lastMessageAt = .now
        try? modelContext.save()
        draft = ""
    }

    private func markRead() {
        for m in messages where !m.isRead { m.isRead = true }
        try? modelContext.save()
    }
}

struct MessageBubble: View {
    let msg: Message
    let isMine: Bool
    var body: some View {
        HStack {
            if isMine { Spacer() }
            Text(msg.text)
                .padding(12)
                .foregroundStyle(isMine ? .white : .primary)
                .background(isMine ? AppTheme.accent : Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .frame(maxWidth: 280, alignment: isMine ? .trailing : .leading)
            if !isMine { Spacer() }
        }
    }
}
