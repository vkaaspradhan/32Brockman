import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let task: CleaningTask?
    let ownerID: UUID

    @State private var title: String
    @State private var area: String
    @State private var frequency: String
    @State private var scheduledDate: Date
    @State private var notes: String
    @State private var assignedTo: String

    private let frequencies = ["Daily", "Weekly", "Monthly", "One-time"]

    init(task: CleaningTask?, ownerID: UUID) {
        self.task = task
        self.ownerID = ownerID
        _title = State(initialValue: task?.title ?? "")
        _area = State(initialValue: task?.area ?? "")
        _frequency = State(initialValue: task?.frequency ?? "Weekly")
        _scheduledDate = State(initialValue: task?.scheduledDate ?? .now)
        _notes = State(initialValue: task?.notes ?? "")
        _assignedTo = State(initialValue: task?.assignedTo ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("Area / Room", text: $area)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { Text($0) }
                    }
                    DatePicker("Scheduled", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Assigned to", text: $assignedTo)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }.disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() {
        let t: CleaningTask
        if let existing = task {
            t = existing
        } else {
            t = CleaningTask(ownerID: ownerID)
            modelContext.insert(t)
        }
        t.title = title
        t.area = area
        t.frequency = frequency
        t.scheduledDate = scheduledDate
        t.notes = notes
        t.assignedTo = assignedTo
        try? modelContext.save()

        // Fire a local notification 15 minutes before the task is due.
        NotificationManager.shared.scheduleReminder(
            id: t.id.uuidString,
            title: "Cleaning: \(t.title)",
            body: t.area.isEmpty ? "Scheduled task due soon" : "In \(t.area)",
            date: t.scheduledDate.addingTimeInterval(-15 * 60))
    }
}
