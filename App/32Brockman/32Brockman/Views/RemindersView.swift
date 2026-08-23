import SwiftUI
import SwiftData

struct RemindersView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.dueDate) private var reminders: [Reminder]
    @State private var showingEditor = false
    @State private var editorReminder: Reminder?

    private var dueSoon: [Reminder] {
        reminders.filter { !$0.isDone }
    }

    var body: some View {
        Group {
            if reminders.isEmpty {
                EmptyState(systemImage: "bell",
                           title: "No reminders",
                           message: "Tap + to set a reminder for any task.")
            } else {
                List {
                    ForEach(reminders) { r in
                        HStack(spacing: 12) {
                            Button { toggle(r) } label: {
                                Image(systemName: r.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(r.isDone ? AppTheme.accent : .secondary)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(r.title).strikethrough(r.isDone).font(.headline)
                                HStack(spacing: 6) {
                                    Text(r.category).font(.caption).foregroundStyle(.secondary)
                                    Text("•").foregroundStyle(.secondary)
                                    Text(r.dueDate, style: .date).font(.caption).foregroundStyle(.secondary)
                                    Text(r.dueDate, style: .time).font(.caption2).foregroundStyle(.tertiary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editorReminder = r; showingEditor = true }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Reminders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { editorReminder = nil; showingEditor = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingEditor) {
            ReminderEditorView(reminder: editorReminder, ownerID: auth.currentUser?.id ?? UUID())
                .presentationDetents([.large])
        }
    }

    private func toggle(_ r: Reminder) {
        r.isDone.toggle()
        if r.isDone, let nid = r.notificationID { NotificationManager.shared.cancel(identifier: nid) }
        try? modelContext.save()
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            let r = reminders[i]
            if let nid = r.notificationID { NotificationManager.shared.cancel(identifier: nid) }
            modelContext.delete(r)
        }
        try? modelContext.save()
    }
}

struct ReminderEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let reminder: Reminder?
    let ownerID: UUID

    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date
    @State private var category: String

    private let categories = ["General", "Cleaning", "Meeting", "Personal", "Work"]

    init(reminder: Reminder?, ownerID: UUID) {
        self.reminder = reminder
        self.ownerID = ownerID
        _title = State(initialValue: reminder?.title ?? "")
        _notes = State(initialValue: reminder?.notes ?? "")
        _dueDate = State(initialValue: reminder?.dueDate ?? .now.addingTimeInterval(3600))
        _category = State(initialValue: reminder?.category ?? "General")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    DatePicker("Due", selection: $dueDate)
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle(reminder == nil ? "New Reminder" : "Edit Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }.disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() {
        let r: Reminder
        if let existing = reminder { r = existing } else {
            r = Reminder(title: "", dueDate: dueDate, ownerID: ownerID)
            modelContext.insert(r)
        }
        r.title = title
        r.notes = notes
        r.dueDate = dueDate
        r.category = category
        try? modelContext.save()

        NotificationManager.shared.scheduleReminder(
            id: r.id.uuidString, title: "Reminder: \(r.title)",
            body: r.notes.isEmpty ? r.category : r.notes, date: r.dueDate)
    }
}
