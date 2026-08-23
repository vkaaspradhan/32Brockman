import SwiftUI
import SwiftData

@main
struct BrockmanApp: App {
    @StateObject private var auth = AuthService()
    let container: ModelContainer

    init() {
        let schema = Schema([
            User.self,
            CleaningTask.self,
            Post.self,
            Conversation.self,
            Message.self,
            Reminder.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        _ = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .environmentObject(auth)
        }
    }
}
