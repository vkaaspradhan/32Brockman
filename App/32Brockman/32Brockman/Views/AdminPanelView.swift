import SwiftUI
import SwiftData

struct AdminPanelView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @State private var selection: AdminTab = .users

    enum AdminTab: String, CaseIterable, Identifiable {
        case users = "Users", posts = "Posts", tasks = "Cleaning", reminders = "Reminders"
        var id: String { rawValue }
    }

    var body: some View {
        List {
            Picker("Section", selection: $selection) {
                ForEach(AdminTab.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)

            switch selection {
            case .users:     AdminUsersSection()
            case .posts:     AdminPostsSection()
            case .tasks:     AdminTasksSection()
            case .reminders: AdminRemindersSection()
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Admin Panel")
    }
}

// MARK: - Users
struct AdminUsersSection: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.createdAt) private var users: [User]
    @State private var showAdd = false

    var body: some View {
        ForEach(users) { u in
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(u.displayName).font(.headline)
                        if u.isAdmin { Text("admin").font(.caption).padding(3).background(.thinMaterial, in: Capsule()) }
                    }
                    Text("@\(u.username)").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if u.id != auth.currentUser?.id {
                    Button(role: .destructive) { delete(u) } label: { Image(systemName: "trash") }
                }
            }
        }
        .onDelete(perform: deleteAt)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "person.badge.plus") }
            }
        }
        .sheet(isPresented: $showAdd) { AddUserSheet() }
    }

    private func delete(_ u: User) {
        if let n = u.id.uuidString as String? { NotificationManager.shared.cancel(identifier: n) }
        modelContext.delete(u)
        try? modelContext.save()
    }
    private func deleteAt(at: IndexSet) {
        for i in at { delete(users[i]) }
    }
}

struct AddUserSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthService
    @State private var username = ""
    @State private var displayName = ""
    @State private var password = ""
    @State private var role = "user"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Username", text: $username).textInputAutocapitalization(.never)
                TextField("Display name", text: $displayName)
                SecureField("Password", text: $password)
                Picker("Role", selection: $role) {
                    Text("User").tag("user")
                    Text("Admin").tag("admin")
                }
            }
            .navigationTitle("Add User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _ = auth.createUser(username: username, password: password,
                                           displayName: displayName.isEmpty ? username : displayName,
                                           role: role)
                        dismiss()
                    }.disabled(username.isEmpty || password.isEmpty)
                }
            }
        }
    }
}

// MARK: - Posts
struct AdminPostsSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]
    var body: some View {
        ForEach(posts) { p in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(p.authorName).font(.subheadline.bold())
                    Spacer()
                    Button(role: .destructive) { delete(p) } label: { Image(systemName: "trash") }
                }
                if !p.text.isEmpty { Text(p.text).font(.caption).lineLimit(2) }
                HStack(spacing: 8) {
                    if !p.imagePaths.isEmpty { Label("\(p.imagePaths.count) img", systemImage: "photo").font(.caption2) }
                    if p.videoPath != nil { Label("video", systemImage: "video").font(.caption2) }
                }.foregroundStyle(.secondary)
            }
        }
    }
    private func delete(_ p: Post) {
        for path in p.imagePaths { MediaStore.shared.remove(at: path) }
        if let v = p.videoPath { MediaStore.shared.remove(at: v) }
        modelContext.delete(p)
        try? modelContext.save()
    }
}

// MARK: - Tasks
struct AdminTasksSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CleaningTask.scheduledDate) private var tasks: [CleaningTask]
    var body: some View {
        ForEach(tasks) { t in
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.title).font(.headline)
                    Text("\(t.frequency) • \(t.assignedTo.isEmpty ? "Unassigned" : t.assignedTo)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(role: .destructive) { delete(t) } label: { Image(systemName: "trash") }
            }
        }
    }
    private func delete(_ t: CleaningTask) {
        if let n = t.id.uuidString as String? { NotificationManager.shared.cancel(identifier: n) }
        modelContext.delete(t)
        try? modelContext.save()
    }
}

// MARK: - Reminders
struct AdminRemindersSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.dueDate) private var reminders: [Reminder]
    var body: some View {
        ForEach(reminders) { r in
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(r.title).font(.headline)
                    Text("\(r.category) • \(r.dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(role: .destructive) { delete(r) } label: { Image(systemName: "trash") }
            }
        }
    }
    private func delete(_ r: Reminder) {
        if let n = r.notificationID { NotificationManager.shared.cancel(identifier: n) }
        modelContext.delete(r)
        try? modelContext.save()
    }
}
