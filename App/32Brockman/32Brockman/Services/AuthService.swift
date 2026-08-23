import Foundation
import SwiftData

final class AuthService: ObservableObject {
    @Published var currentUserID: UUID?
    @Published var isAuthenticated = false
    @Published var modelContext: ModelContext?

    var currentUser: User? {
        guard let id = currentUserID, let ctx = modelContext else { return nil }
        let fetch = FetchDescriptor<User>(predicate: #Predicate { $0.id == id })
        return try? ctx.fetch(fetch).first
    }

    func attach(_ context: ModelContext) {
        modelContext = context
        if !hasUsers(context) { seedAccounts(in: context) }
    }

    private func hasUsers(_ ctx: ModelContext) -> Bool {
        (try? ctx.fetchCount(FetchDescriptor<User>())) ?? 0 > 0
    }

    private func seedAccounts(in ctx: ModelContext) {
        let admin = User(username: "admin",
                         passwordHash: hashPassword("admin123"),
                         displayName: "Administrator",
                         role: "admin")
        let demo = User(username: "user",
                        passwordHash: hashPassword("user123"),
                        displayName: "Demo User",
                        role: "user")
        ctx.insert(admin)
        ctx.insert(demo)
        try? ctx.save()
    }

    func login(username: String, password: String) -> Bool {
        guard let ctx = modelContext else { return false }
        let hash = hashPassword(password)
        let fetch = FetchDescriptor<User>(
            predicate: #Predicate { $0.username == username && $0.passwordHash == hash }
        )
        guard let user = try? ctx.fetch(fetch).first, user.isActive else { return false }
        currentUserID = user.id
        isAuthenticated = true
        return true
    }

    func logout() {
        currentUserID = nil
        isAuthenticated = false
    }

    func createUser(username: String, password: String, displayName: String, role: String) -> User? {
        guard let ctx = modelContext else { return nil }
        let u = User(username: username, passwordHash: hashPassword(password),
                     displayName: displayName, role: role)
        ctx.insert(u)
        try? ctx.save()
        return u
    }

    func deleteUser(_ user: User) {
        guard let ctx = modelContext else { return }
        ctx.delete(user)
        try? ctx.save()
    }
}
