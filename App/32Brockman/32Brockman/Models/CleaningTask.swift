import Foundation
import SwiftData

@Model
final class CleaningTask {
    var id: UUID
    var title: String
    var area: String
    var frequency: String
    var scheduledDate: Date
    var isDone: Bool
    var notes: String
    var assignedTo: String
    var ownerID: UUID
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        area: String = "",
        frequency: String = "Weekly",
        scheduledDate: Date = .now,
        isDone: Bool = false,
        notes: String = "",
        assignedTo: String = "",
        ownerID: UUID
    ) {
        self.id = id
        self.title = title
        self.area = area
        self.frequency = frequency
        self.scheduledDate = scheduledDate
        self.isDone = isDone
        self.notes = notes
        self.assignedTo = assignedTo
        self.ownerID = ownerID
        self.createdAt = .now
    }
}
