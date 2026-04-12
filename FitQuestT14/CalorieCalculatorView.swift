//
//  CalorieCalculatorView.swift
//  FitQuestT14
//
//  Created by Trung Anh Nguyen on 2026-04-05.
//

import SwiftUI

struct CalorieCalculatorView: View {

    @State private var selectedType: WorkoutType = .cardio

    // Cardio inputs
    @State private var minutes:      String = ""
    @State private var selectedCardio: String = "Running"

    // Strength inputs
    @State private var reps:            String = ""
    @State private var sets:            String = ""
    @State private var selectedStrength: String = "Push-ups"

    // Weight — auto-filled from profile
    @State private var weight: String = ""

    // Result
    @State private var result: Double? = nil

    let cardioOptions   = ["Running", "Cycling"]
    let strengthOptions = ["Push-ups", "Squats"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Type Picker
                    Picker("Workout Type", selection: $selectedType) {
                        Text("Cardio").tag(WorkoutType.cardio)
                        Text("Strength").tag(WorkoutType.strength)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) { result = nil }

                    // Inputs
                    VStack(spacing: 14) {
                        if selectedType == .cardio {
                            // Activity picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Activity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("Activity", selection: $selectedCardio) {
                                    ForEach(cardioOptions, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                            InputField(label: "Duration (minutes)", text: $minutes, placeholder: "e.g. 30")
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Exercise")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("Exercise", selection: $selectedStrength) {
                                    ForEach(strengthOptions, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                            InputField(label: "Reps per set", text: $reps, placeholder: "e.g. 12")
                            InputField(label: "Number of sets", text: $sets, placeholder: "e.g. 4")
                        }

                        // Weight field — pre-filled from profile
                        InputField(label: "Your Weight (kg)", text: $weight, placeholder: "e.g. 70")
                        Text("Weight is auto-filled from your Profile. You can override it here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MET Info Banner
                    let workoutName = selectedType == .cardio ? selectedCardio : selectedStrength
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("MET value for \(workoutName): \(String(format: "%.1f", CalorieCalculator.met(for: workoutName)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                    // Calculate Button
                    Button {
                        calculate()
                    } label: {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }

                    // Result
                    if let result {
                        VStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.orange)
                            Text("\(Int(result)) kcal")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.primary)
                            Text("estimated calories burned")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Formula: MET × weight × duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()
                }
                .padding()
                .animation(.easeInOut, value: result)
            }
            .navigationTitle("Calorie Calculator")
            .onAppear { loadWeight() }
        }
    }

    private func loadWeight() {
        weight = UserDefaults.standard.string(forKey: "profile_weight") ?? ""
    }

    private func calculate() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard let w = Double(weight), w > 0 else { return }

        if selectedType == .cardio {
            guard let m = Double(minutes), m > 0 else { return }
            let met = CalorieCalculator.met(for: selectedCardio)
            result = CalorieCalculator.cardio(minutes: m, met: met, weightKg: w)
        } else {
            guard let r = Double(reps), let s = Double(sets), r > 0, s > 0 else { return }
            let met = CalorieCalculator.met(for: selectedStrength)
            result = CalorieCalculator.strength(reps: r, sets: s, met: met, weightKg: w)
        }
    }
}

// MARK: - Reusable input field
private struct InputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
}
