import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if auth.isAuthenticated, auth.currentUser != nil {
                HomeView()
                    .onAppear { requestNotifications() }
            } else {
                LoginView()
            }
        }
        .onAppear { auth.attach(modelContext) }
    }

    private func requestNotifications() {
        Task {
            if NotificationManager.shared.authorizationStatus == .notDetermined {
                await NotificationManager.shared.requestAuthorization()
            }
        }
    }
}
