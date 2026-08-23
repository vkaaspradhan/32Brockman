import SwiftUI
import SwiftData

struct CleaningSchedulerView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CleaningTask.scheduledDate) private var tasks: [CleaningTask]
    @State private var showingEditor = false
    @State private var editorTask: CleaningTask?

    var body: some View {
        Group {
            if tasks.isEmpty {
                EmptyState(systemImage: "sparkle",
                           title: "No routines yet",
                           message: "Tap + to add your first cleaning task.")
            } else {
                List {
                    ForEach(tasks) { task in
                        HStack(spacing: 12) {
                            Button {
                                toggle(task)
                            } label: {
                                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isDone ? AppTheme.accent : .secondary)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(task.title)
                                    .strikethrough(task.isDone)
                                    .font(.headline)
                                HStack(spacing: 6) {
                                    if !task.area.isEmpty {
                                        Text(task.area).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Text("•").foregroundStyle(.secondary)
                                    Text(task.frequency).font(.caption).foregroundStyle(.secondary)
                                }
                                Text(task.scheduledDate, style: .date)
                                    .font(.caption2).foregroundStyle(.tertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editorTask = task; showingEditor = true }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Cleaning Routines")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editorTask = nil
                    showingEditor = true
                } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingEditor) {
            TaskEditorView(task: editorTask, ownerID: auth.currentUser?.id ?? UUID())
                .presentationDetents([.large])
        }
    }

    private func toggle(_ task: CleaningTask) {
        task.isDone.toggle()
        try? modelContext.save()
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            let t = tasks[i]
            if let nid = t.id.uuidString as String? { NotificationManager.shared.cancel(identifier: nid) }
            modelContext.delete(t)
        }
        try? modelContext.save()
    }
}
