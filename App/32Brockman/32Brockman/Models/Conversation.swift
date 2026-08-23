import Foundation
import SwiftData

@Model
final class Conversation {
    var id: UUID
    var participantIDs: [UUID]
    var lastMessageText: String
    var lastMessageAt: Date

    init(
        id: UUID = UUID(),
        participantIDs: [UUID],
        lastMessageText: String = "",
        lastMessageAt: Date = .now
    ) {
        self.id = id
        self.participantIDs = participantIDs
        self.lastMessageText = lastMessageText
        self.lastMessageAt = lastMessageAt
    }
}
