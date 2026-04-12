import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout

    @EnvironmentObject var store: WorkoutStore

    @State private var isRunning      = false
    @State private var calories: Double = 0
    @State private var showResult     = false

    @State private var inputMinutes: String = ""
    @State private var speed:        String = ""
    @State private var timeRemaining: Int   = 0

    @State private var reps: String = ""
    @State private var sets: String = ""

    @State private var timerHolder = TimerHolder()

    // Load weight from profile (default 70kg if not set)
    private var weightKg: Double {
        let stored = UserDefaults.standard.string(forKey: "profile_weight") ?? ""
        return Double(stored) ?? 70.0
    }

    private var minutesValue: Double? { Double(inputMinutes).flatMap { $0 > 0 ? $0 : nil } }
    private var speedValue:   Double? { Double(speed).flatMap   { $0 > 0 ? $0 : nil } }
    private var repsValue:    Double? { Double(reps).flatMap    { $0 > 0 ? $0 : nil } }
    private var setsValue:    Double? { Double(sets).flatMap    { $0 > 0 ? $0 : nil } }

    private var cardioInputsValid:   Bool { minutesValue != nil && speedValue != nil }
    private var strengthInputsValid: Bool { repsValue != nil && setsValue != nil }
    private var canCalculate: Bool {
        workout.type == .cardio ? cardioInputsValid : strengthInputsValid
    }
    private var canStart: Bool { cardioInputsValid }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }

            VStack(spacing: 20) {

                if workout.type == .cardio {

                    ValidatedField(
                        label: "Minutes",
                        text: $inputMinutes,
                        isValid: minutesValue != nil || inputMinutes.isEmpty,
                        keyboardType: .numberPad
                    )

                    ValidatedField(
                        label: "Speed (km/h)",
                        text: $speed,
                        isValid: speedValue != nil || speed.isEmpty,
                        keyboardType: .decimalPad
                    )

                    Text("Time Remaining: \(timeRemaining)s")

                } else {

                    ValidatedField(
                        label: "Reps",
                        text: $reps,
                        isValid: repsValue != nil || reps.isEmpty,
                        keyboardType: .numberPad
                    )

                    ValidatedField(
                        label: "Sets",
                        text: $sets,
                        isValid: setsValue != nil || sets.isEmpty,
                        keyboardType: .numberPad
                    )
                }

                Text("Calories: \(calories, specifier: "%.2f")")
                    .font(.headline)

                VStack(spacing: 12) {

                    if workout.type == .cardio {
                        Button(isRunning ? "Stop" : "Start") {
                            isRunning ? stopWorkout() : startWorkout()
                        }
                        .disabled(!canStart && !isRunning)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunning ? Color.red : (canStart ? Color.green : Color.gray.opacity(0.4)))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button("Calculate Calories") {
                        calculateCalories()
                    }
                    .disabled(!canCalculate)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canCalculate ? Color.blue : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Reset") { resetWorkout() }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(workout.name)
        .onDisappear {
            timerHolder.stop()
        }
        .sheet(isPresented: $showResult) {
            ResultSheet(calories: calories, onSave: {
                saveWorkout()
                showResult = false
            }, onClose: {
                showResult = false
            })
        }
    }

    func startWorkout() {
        guard workout.type == .cardio,
              let mins = minutesValue,
              let spd  = speedValue else { return }

        isRunning     = true
        timeRemaining = Int(mins) * 60
        calories      = 0

        timerHolder.start(interval: 1.0) {
            DispatchQueue.main.async {
                guard isRunning else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    calories += CalorieCalculator.cardioPerSecond(speed: spd, weightKg: weightKg)
                } else {
                    stopWorkout()
                }
            }
        }
    }

    func stopWorkout() {
        timerHolder.stop()
        isRunning  = false
        showResult = true
    }

    func calculateCalories() {
        let met = CalorieCalculator.met(for: workout.name)
        if workout.type == .cardio {
            calories = CalorieCalculator.cardio(
                minutes: minutesValue ?? 0,
                met: met,
                weightKg: weightKg
            )
        } else {
            calories = CalorieCalculator.strength(
                reps: repsValue ?? 0,
                sets: setsValue ?? 0,
                met: met,
                weightKg: weightKg
            )
        }
        showResult = true
    }

    func resetWorkout() {
        timerHolder.stop()
        isRunning     = false
        calories      = 0
        timeRemaining = 0
        reps = ""; sets = ""; inputMinutes = ""; speed = ""
    }

    func saveWorkout() {
        guard calories > 0 else { return }
        store.save(session: WorkoutSession(name: workout.name, calories: calories, date: Date()))
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
