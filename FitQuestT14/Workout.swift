import Foundation

enum WorkoutType: String, Codable, CaseIterable {
    case cardio
    case strength
}

struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let type: WorkoutType
}

extension Workout {
    static let all: [Workout] = [
        Workout(name: "Running",  type: .cardio),
        Workout(name: "Cycling",  type: .cardio),
        Workout(name: "Push-ups", type: .strength),
        Workout(name: "Squats",   type: .strength),
    ]
}

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Double
    let date: Date

    init(name: String, calories: Double, date: Date) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.date = date
    }
}
