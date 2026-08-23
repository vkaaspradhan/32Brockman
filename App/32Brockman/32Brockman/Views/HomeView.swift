import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var auth: AuthService
    @State private var selection: Tab = .cleaning
    @State private var showAdmin = false

    enum Tab: Hashable {
        case cleaning, posts, chat, reminders
    }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { CleaningSchedulerView() }
                .tabItem { Label("Cleaning", systemImage: "sparkle") }
                .tag(Tab.cleaning)

            NavigationStack { PostsView() }
                .tabItem { Label("Posts", systemImage: "square.and.pencil") }
                .tag(Tab.posts)

            NavigationStack { ChatListView() }
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }
                .tag(Tab.chat)

            NavigationStack { RemindersView() }
                .tabItem { Label("Reminders", systemImage: "bell") }
                .tag(Tab.reminders)
        }
        .accentColor(AppTheme.accent)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if auth.currentUser?.isAdmin == true {
                        Button {
                            showAdmin = true
                        } label: {
                            Label("Admin Panel", systemImage: "shield")
                        }
                    }
                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Label("Account", systemImage: "person.circle")
                }
            }
        }
        .sheet(isPresented: $showAdmin) {
            NavigationStack { AdminPanelView() }
                .presentationDetents([.large])
        }
    }
}
