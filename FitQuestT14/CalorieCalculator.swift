import Foundation

enum CalorieCalculator {
    private static let metValues: [String: Double] = [
        "Running":  8.0,
        "Cycling":  6.0,
        "Push-ups": 3.8,
        "Squats":   5.0
    ]

    static func cardio(minutes: Double, met: Double, weightKg: Double) -> Double {
        let hours = minutes / 60.0
        return met * weightKg * hours
    }

    static func strength(reps: Double, sets: Double, met: Double, weightKg: Double) -> Double {
        let minutes = (reps * sets * 3.0) / 60.0
        return met * weightKg * (minutes / 60.0)
    }

    static func met(for workoutName: String) -> Double {
        return metValues[workoutName] ?? 5.0
    }

    static func cardioPerSecond(speed: Double, weightKg: Double) -> Double {
        let met = speed < 8 ? 6.0 : 8.0
        return (met * weightKg) / 3600.0
    }
}
