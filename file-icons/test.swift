import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?

    init(title: String, dueDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.dueDate = dueDate
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []

    func addTask(_ title: String) {
        let task = Task(title: title)
        tasks.append(task)
    }

    func toggleComplete(for id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    var pendingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
}
