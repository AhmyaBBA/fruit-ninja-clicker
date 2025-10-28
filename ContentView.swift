import SwiftUI

// A prize struct that has the number of clicks you need (threshold),
// the title of the award, and a description.
// This helps keep the prizes organized in one place.
struct Prize: Hashable {
    let threshold: Int
    let title: String
    let detail: String
}

// Enum for fruits. Each fruit has an emoji and a name.
// I used an enum because it’s easier to pick a random fruit this way.
enum Fruit: CaseIterable {
    case apple, banana, watermelon, orange, grape
    
    var emoji: String {
        switch self {
        case .apple: return "🍎"
        case .banana: return "🍌"
        case .watermelon: return "🍉"
        case .orange: return "🍊"
        case .grape: return "🍇"
        }
    }
    
    var name: String {
        switch self {
        case .apple: return "Apple"
        case .banana: return "Banana"
        case .watermelon: return "Watermelon"
        case .orange: return "Orange"
        case .grape: return "Grape"
        }
    }
}

struct ContentView: View {
    // variables for the game
    @State private var taps = 0                  // keeps track of total clicks
    @State private var currentFruit: Fruit = .apple
    @State private var earnedPrizes: [Prize] = [] // stores all prizes the player got
    @State private var latestPrize: Prize? = nil
    @State private var showPrizeAlert = false    // controls when the alert pops up
    
    // just for some fun animation so the fruit moves and spins
    @State private var flyOffset: CGSize = .zero
    @State private var spin: Double = 0
    @State private var popScale: CGFloat = 1.0
    
    // these are the prizes the user can unlock
    let prizes: [Prize] = [
        Prize(threshold: 10,  title: "Wooden Blade 🗡️",   detail: "10 slices! Warming up."),
        Prize(threshold: 25,  title: "Steel Katana ⚔️",   detail: "25 slices! Getting sharp."),
        Prize(threshold: 50,  title: "Lightning Saber ⚡️",detail: "50 slices! Blazing fast."),
        Prize(threshold: 100, title: "Grand Fruit Master 👑", detail: "100 slices! Legendary.")
    ]
    
    // makes the fruit move around every second or so
    let motionTimer = Timer.publish(every: 1.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // background color
            LinearGradient(colors: [.green.opacity(0.25), .mint.opacity(0.25)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 22) {
                // header text and counter (main requirement of the project)
                VStack(spacing: 6) {
                    Text("Fruit Ninja Clicker")
                        .font(.system(size: 28, weight: .bold))
                    Text("Clicks: \(taps)") // shows how many times user clicked
                        .font(.system(size: 36, weight: .heavy))
                }
                .padding(.top, 16)
                
                // this is the fruit button the user taps on
                ZStack {
                    Button {
                        handleTap() // function gets called each tap
                    } label: {
                        Text(currentFruit.emoji)
                            .font(.system(size: 100))
                            .padding(24)
                            .background(.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .scaleEffect(popScale)
                            .rotationEffect(.degrees(spin))
                            .offset(flyOffset)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 280)
                .padding(.vertical, 8)
                
                // list of all awards the user unlocked
                if !earnedPrizes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Awards")
                            .font(.headline)
                        ForEach(earnedPrizes, id: \.self) { p in
                            Text("• \(p.title) — \(p.detail)")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
                
                // reset buttons for testing the game
                HStack(spacing: 12) {
                    Button("Reset Count") {
                        taps = 0
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.red.opacity(0.15))
                    .clipShape(Capsule())
                    
                    Button("New Game") {
                        resetGame()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.blue.opacity(0.15))
                    .clipShape(Capsule())
                }
                .font(.callout)
                
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        // this shows when you unlock a prize
        .alert("Award Unlocked!", isPresented: $showPrizeAlert) {
            Button("Nice!") {}
        } message: {
            Text("\(latestPrize?.title ?? "")\n\(latestPrize?.detail ?? "")")
        }
        // keeps the fruit moving
        .onReceive(motionTimer) { _ in
            flyFruit()
        }
    }
    
    // MARK: - Functions
    
    // function that runs every time the fruit is tapped
    func handleTap() {
        taps += 1  // adds 1 to the click counter
        
        // some simple animations just to make it more fun
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { popScale = 1.12 }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7).delay(0.05)) { popScale = 1.0 }
        withAnimation(.easeIn(duration: 0.25)) { spin += 90 }
        
        // check if the user earned a new prize
        checkAwardsForClickCount()
        
        // switch to a new random fruit
        currentFruit = Fruit.allCases.randomElement() ?? .apple
    }
    
    // makes the fruit move around
    func flyFruit() {
        let maxX: CGFloat = 80
        let maxY: CGFloat = 60
        withAnimation(.easeInOut(duration: 1.0)) {
            flyOffset = CGSize(width: CGFloat.random(in: -maxX...maxX),
                               height: CGFloat.random(in: -maxY...maxY))
        }
    }
    
    // checks if the click count hit a prize threshold
    func checkAwardsForClickCount() {
        if taps == 10 {
            unlockPrize(Prize(threshold: 10, title: "Wooden Blade 🗡️",   detail: "10 slices! Warming up."))
        } else if taps == 25 {
            unlockPrize(Prize(threshold: 25, title: "Steel Katana ⚔️",   detail: "25 slices! Getting sharp."))
        } else if taps == 50 {
            unlockPrize(Prize(threshold: 50, title: "Lightning Saber ⚡️",detail: "50 slices! Blazing fast."))
        } else if taps == 100 {
            unlockPrize(Prize(threshold: 100, title: "Grand Fruit Master 👑", detail: "100 slices! Legendary."))
        }
    }
    
    // adds the prize to the list and shows an alert
    func unlockPrize(_ prize: Prize) {
        if !earnedPrizes.contains(prize) {
            earnedPrizes.append(prize)
            latestPrize = prize
            showPrizeAlert = true
        }
    }
    
    // resets the whole game
    func resetGame() {
        taps = 0
        earnedPrizes.removeAll()
        latestPrize = nil
        currentFruit = .apple
        flyOffset = .zero
        spin = 0
        popScale = 1.0
    }
}

#Preview {
    ContentView()
}
