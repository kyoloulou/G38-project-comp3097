import Foundation
import Combine

class WorkoutStore: ObservableObject {
    @Published var sessions: [WorkoutSession] = []

    private let key = "workouts"

    init() { load() }

    func save(session: WorkoutSession) {
        sessions.append(session)
        persist()
    }

    func delete(session: WorkoutSession) {
        sessions.removeAll { $0.id == session.id }
        persist()
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            sessions = decoded
        }
    }
}
