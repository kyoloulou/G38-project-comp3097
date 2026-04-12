import SwiftUI

struct WorkoutRow: View {
    let workout: Workout

    var iconName: String {
        switch workout.name {
        case "Running":  return "figure.run"
        case "Cycling":  return "figure.outdoor.cycle"
        case "Push-ups": return "figure.strengthtraining.traditional"
        case "Squats":   return "figure.strengthtraining.functional"
        default:         return workout.type == .cardio ? "heart.fill" : "dumbbell.fill"
        }
    }

    var accentColor: Color {
        workout.type == .cardio ? .blue : .orange
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(accentColor)
                .frame(width: 44, height: 44)
                .background(accentColor.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(workout.type == .cardio ? "Cardio" : "Strength")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
