import SwiftUI

// MARK: - Model

struct RatingEntry: Identifiable {
    let id = UUID()
    let value: Int
}

// MARK: - Root View

struct ContentView: View {
    @State private var ratings: [RatingEntry] = []
    @State private var inputDigits = ""

    // Combined formula: 1 − ∏(1 − Aᵢ/100)
    var combinedRating: Double {
        guard !ratings.isEmpty else { return 0 }
        return (1.0 - ratings.reduce(1.0) { $0 * (1.0 - Double($1.value) / 100.0) }) * 100.0
    }

    var roundedResult: Int { Int(combinedRating.rounded()) }

    var inputValue: Int? {
        guard let v = Int(inputDigits), v >= 1, v <= 99 else { return nil }
        return v
    }

    var body: some View {
        ZStack {
            ambientBackground

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 24)
                    .padding(.top, 56)

                resultDisplay
                    .padding(.top, 4)

                Spacer()

                ratingsScroll

                Spacer()

                numpadPanel
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Background

    var ambientBackground: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.17)
                .ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.42, green: 0.18, blue: 0.95).opacity(0.38), .clear],
                center: .init(x: 0.15, y: 0.08),
                startRadius: 0, endRadius: 380
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.08, green: 0.28, blue: 0.95).opacity(0.30), .clear],
                center: .init(x: 0.88, y: 0.74),
                startRadius: 0, endRadius: 320
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    var headerBar: some View {
        HStack {
            Text("Impairment Combiner")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
            Spacer()
            if !ratings.isEmpty {
                Button("Clear all") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        ratings.removeAll()
                    }
                    inputDigits = ""
                }
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: ratings.isEmpty)
    }

    // MARK: - Result Display

    var resultDisplay: some View {
        VStack(spacing: 6) {
            Text("COMBINED IMPAIRMENT")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .tracking(3.0)
                .foregroundStyle(.white.opacity(0.62))
                .padding(.top, 44)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(ratings.isEmpty ? "—" : "\(roundedResult)")
                    .font(.system(size: 100, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.48, dampingFraction: 0.76), value: roundedResult)

                if !ratings.isEmpty {
                    Text("%")
                        .font(.system(size: 44, weight: .thin, design: .rounded))
                        .foregroundStyle(.white.opacity(0.52))
                        .padding(.leading, 3)
                        .padding(.bottom, 8)
                }
            }

            subtitleText
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.52))
                .animation(.easeInOut(duration: 0.2), value: ratings.count)

            Text("A + B(1 − A)")
                .font(.system(size: 15, weight: .light, design: .monospaced))
                .foregroundStyle(.white.opacity(0.38))
                .padding(.top, 10)
        }
    }

    @ViewBuilder
    var subtitleText: some View {
        if ratings.isEmpty {
            Text("Enter impairment ratings below")
        } else if ratings.count == 1 {
            Text("1 rating — add more to combine")
        } else {
            let exact = combinedRating
            let rounded = Double(roundedResult)
            if abs(exact - rounded) > 0.05 {
                Text("\(ratings.count) ratings · exact \(String(format: "%.1f", exact))%")
            } else {
                Text("\(ratings.count) ratings combined")
            }
        }
    }

    // MARK: - Ratings Row

    var ratingsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ratings) { entry in
                    RatingPill(value: entry.value) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            ratings.removeAll { $0.id == entry.id }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.55, anchor: .bottom).combined(with: .opacity),
                        removal: .scale(scale: 0.55).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.36, dampingFraction: 0.8), value: ratings.count)
        }
        .frame(height: ratings.isEmpty ? 0 : 52)
        .animation(.easeInOut(duration: 0.2), value: ratings.isEmpty)
    }

    // MARK: - Numpad Panel

    var numpadPanel: some View {
        VStack(spacing: 0) {
            inputPreview
                .padding(.vertical, 18)

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 0.5)
                .padding(.horizontal, 20)

            numpadGrid
                .padding(.top, 21)
                .padding(.bottom, 22)
                .padding(.horizontal, 18)
        }
        .background {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.32),
                                    .white.opacity(0.10),
                                    .white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }

    var inputPreview: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Spacer()
            if inputDigits.isEmpty {
                Text("—")
                    .font(.system(size: 54, weight: .thin, design: .rounded))
                    .foregroundStyle(.white.opacity(0.36))
            } else {
                Text(inputDigits)
                    .font(.system(size: 54, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.24, dampingFraction: 0.8), value: inputDigits)
                Text("%")
                    .font(.system(size: 28, weight: .thin, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 3)
                    .padding(.leading, 3)
            }
            Spacer()
        }
    }

    let keyRows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["⌫", "0", "+"]
    ]

    var numpadGrid: some View {
        VStack(spacing: 9) {
            ForEach(keyRows.indices, id: \.self) { i in
                HStack(spacing: 9) {
                    ForEach(keyRows[i], id: \.self) { key in
                        NumpadKeyView(
                            key: key,
                            isEnabled: keyEnabled(key),
                            isAdd: key == "+"
                        ) {
                            handleKey(key)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Logic

    func keyEnabled(_ key: String) -> Bool {
        switch key {
        case "+": return inputValue != nil
        case "⌫": return !inputDigits.isEmpty
        default:  return inputDigits.count < 2
        }
    }

    func handleKey(_ key: String) {
        switch key {
        case "⌫":
            guard !inputDigits.isEmpty else { return }
            inputDigits.removeLast()

        case "+":
            guard let v = inputValue else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                ratings.append(RatingEntry(value: v))
            }
            inputDigits = ""

        default:
            guard inputDigits.count < 2 else { return }
            let proposed = inputDigits + key
            if let v = Int(proposed), v >= 1, v <= 99 {
                inputDigits = proposed
            }
        }
    }
}

// MARK: - Rating Pill

struct RatingPill: View {
    let value: Int
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: 5) {
                Text("\(value)%")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .opacity(0.5)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background {
                Capsule()
                    .fill(.white.opacity(0.10))
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.20), lineWidth: 0.75)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Numpad Key

struct NumpadKeyView: View {
    let key: String
    let isEnabled: Bool
    let isAdd: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                keyBackground
                keyLabel
            }
            .frame(maxWidth: .infinity)
            .frame(height: 66)
        }
        .buttonStyle(GlassButtonStyle())
        .disabled(!isEnabled)
    }

    @ViewBuilder
    var keyBackground: some View {
        if isAdd {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    isEnabled
                    ? LinearGradient(
                        colors: [
                            Color(red: 0.28, green: 0.52, blue: 1.0),
                            Color(red: 0.12, green: 0.32, blue: 0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [.white.opacity(0.07), .white.opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(isEnabled ? 0.30 : 0.08), lineWidth: 0.75)
                )
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(key == "⌫" ? 0.06 : 0.085))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 0.75)
                )
        }
    }

    @ViewBuilder
    var keyLabel: some View {
        if isAdd {
            Image(systemName: "plus")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white.opacity(isEnabled ? 1 : 0.22))
        } else if key == "⌫" {
            Image(systemName: "delete.left")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(.white.opacity(isEnabled ? 0.72 : 0.22))
        } else {
            Text(key)
                .font(.system(size: 26, weight: .light, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Button Style

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.62), value: configuration.isPressed)
    }
}
