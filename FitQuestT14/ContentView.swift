import SwiftUI
import Charts

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
        TabView {

            // ── Tab 1: Workouts + Progress ──────────────────────────
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

                        // ── Bar Chart ──────────────────────────────
                        if !store.sessions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calories Per Session")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Chart {
                                    ForEach(sortedSessions.prefix(10).reversed()) { session in
                                        BarMark(
                                            x: .value("Date", session.date, unit: .day),
                                            y: .value("Calories", session.calories)
                                        )
                                        .foregroundStyle(Color.blue.gradient)
                                        .cornerRadius(4)
                                    }
                                }
                                .frame(height: 180)
                                .chartXAxis {
                                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisGridLine()
                                        AxisValueLabel("\(value.as(Int.self) ?? 0) kcal")
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }

                        // ── Session History ────────────────────────
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
            }
            .tabItem {
                Label("Workouts", systemImage: "figure.run")
            }

            // ── Tab 2: Calorie Calculator ───────────────────────────
            CalorieCalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "flame.fill")
                }

            // ── Tab 3: Profile ──────────────────────────────────────
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
