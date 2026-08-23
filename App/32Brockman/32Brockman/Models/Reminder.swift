import Foundation
import SwiftData

@Model
final class Reminder {
    var id: UUID
    var title: String
    var notes: String
    var dueDate: Date
    var isDone: Bool
    var category: String
    var ownerID: UUID
    var notificationID: String?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        dueDate: Date,
        category: String = "General",
        ownerID: UUID,
        isDone: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isDone = isDone
        self.category = category
        self.ownerID = ownerID
        self.notificationID = id.uuidString
    }
}
