import Foundation

enum CalorieCalculator {
    static func cardio(minutes: Double, speed: Double) -> Double {
        minutes * speed * 0.5
    }
    static func strength(reps: Double, sets: Double) -> Double {
        reps * sets * 0.5
    }
    static func cardioPerSecond(speed: Double) -> Double {
        speed * 0.02
    }
}
