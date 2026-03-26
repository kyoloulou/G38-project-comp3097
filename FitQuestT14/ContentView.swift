import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: WorkoutStore
    @EnvironmentObject var auth: AuthStore

    var totalCalories: Double {
        store.sessions.reduce(0) { $0 + $1.calories }
    }

    var sortedSessions: [WorkoutSession] {
        store.sessions.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    SectionHeader(title: "Workouts", systemImage: "figure.run")

                    VStack(spacing: 12) {
                        ForEach(Workout.all) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                WorkoutRow(workout: workout)
                            }
                        }
                    }

                    Divider()

                    SectionHeader(title: "Progress", systemImage: "chart.bar.fill")

                    HStack {
                        StatBadge(label: "Total Burned", value: "\(Int(totalCalories)) kcal", color: .green)
                        Spacer()
                        StatBadge(label: "Sessions", value: "\(store.sessions.count)", color: .blue)
                    }

                    if store.sessions.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 36))
                                    .foregroundColor(.secondary)
                                Text("No workouts yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 24)
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(sortedSessions.enumerated()), id: \.element.id) { index, session in
                                SessionRow(session: session)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            store.delete(session: session)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                if index < sortedSessions.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("FitQuest")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        auth.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.footnote)
                    }
                    .tint(.red)
                }
            }
        }
    }
}
