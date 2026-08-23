import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var username: String
    var passwordHash: String
    var displayName: String
    var role: String
    var createdAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        username: String,
        passwordHash: String,
        displayName: String,
        role: String = "user",
        createdAt: Date = .now,
        isActive: Bool = true
    ) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.displayName = displayName
        self.role = role
        self.createdAt = createdAt
        self.isActive = isActive
    }

    var isAdmin: Bool { role == "admin" }
}
