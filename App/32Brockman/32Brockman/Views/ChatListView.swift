import SwiftUI
import SwiftData

struct ChatListView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.lastMessageAt, order: .reverse) private var conversations: [Conversation]

    var body: some View {
        Group {
            if conversations.isEmpty {
                EmptyState(systemImage: "bubble.left.and.bubble.right",
                           title: "No chats yet",
                           message: "Start a chat with another member below.")
            } else {
                List(conversations) { conv in
                    NavigationLink {
                        ConversationView(conversation: conv)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(participantNames(conv))
                                .font(.headline)
                            Text(conv.lastMessageText.isEmpty ? "No messages" : conv.lastMessageText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(otherUsers, id: \.id) { u in
                        Button(u.displayName) { startChat(with: u) }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var otherUsers: [User] {
        guard let me = auth.currentUser else { return [] }
        let all = (try? modelContext.fetch(FetchDescriptor<User>())) ?? []
        return all.filter { $0.id != me.id && $0.isActive }
    }

    private func participantNames(_ conv: Conversation) -> String {
        guard let me = auth.currentUser else { return "Chat" }
        let all = (try? modelContext.fetch(FetchDescriptor<User>())) ?? []
        let byId = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        let names = conv.participantIDs.compactMap { id -> String? in
            if id == me.id { return nil }
            return byId[id]?.displayName
        }
        return names.isEmpty ? "Chat" : names.joined(separator: ", ")
    }

    private func startChat(with user: User) {
        guard let me = auth.currentUser else { return }
        let conv = Conversation(participantIDs: [me.id, user.id])
        modelContext.insert(conv)
        try? modelContext.save()
    }
}
