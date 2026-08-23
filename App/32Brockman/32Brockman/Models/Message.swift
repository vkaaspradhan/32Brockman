import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var conversationID: UUID
    var senderID: UUID
    var text: String
    var createdAt: Date
    var isRead: Bool

    init(
        id: UUID = UUID(),
        conversationID: UUID,
        senderID: UUID,
        text: String,
        createdAt: Date = .now,
        isRead: Bool = false
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.createdAt = createdAt
        self.isRead = isRead
    }
}
