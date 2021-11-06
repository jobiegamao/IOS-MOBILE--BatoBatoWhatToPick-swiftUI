import SwiftUI

struct ContentView: View {
    @State private var currentMove = Int.random(in: 0...2)
    @State private var winCondition = Bool.random()
    @State private var score = 0
    @State private var lives = 3
    
    @State private var gameEnd = false
    @State private var scoreTitle = ""
    
    @State private var moves = ["✊", "✋", "✌️"]
    
    @State private var timeRemaining = 45
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isActive = true
    
    @AppStorage("highscore") var highscore: Int = 0
    
    var body: some View {
        
        VStack(spacing: 80) {
            VStack(spacing: 50) {
                Text("""
                    Score: \(score)
                    Lives: \(lives)
                    """)
                    .multilineTextAlignment(.center)
                
                VStack {
                    Text("Time: \(timeRemaining)")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.primary)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        )
                    Text("The move is:")
                    Text(moves[currentMove])
                        .font(.system(size: 60))
                        .fontWeight(.black)
                }
                
                HStack {
                    Text("You need to ") +
                    Text(winCondition ? "WIN" : "LOSE")
                        .foregroundColor(winCondition ? .green : .red)
                        .fontWeight(.bold)
                }
                .font(.largeTitle)
            }
            .font(.title)
            .foregroundColor(.primary)
            
            // Moves
            HStack(spacing:10) {
                ForEach(0 ..< 3) { number in
                    Button(action: {
                        self.optionSelected(number)
                    }) {
                        Text(self.moves[number])
                            .foregroundColor(.primary)
                            .font(.system(size: 60))
                    }
                }
            }
        }
        // Runs the timer and check if the time has ended
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
        // Pause the timer if application is out of focus
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.isActive = true
        }
        
        // Game over alert
        .alert(isPresented: $gameEnd) {
                        Alert(title: Text(scoreTitle), message: Text("High score: \(highscore)"), dismissButton: .default(Text("Try Again")) {
                            self.restartGame()
                        })
        }
    }
    
    // Gives a new move and win condition
    func newMove() {
        currentMove = Int.random(in: 0...2)
        winCondition = Bool.random()
    }
    
    // Called after pressing Try Again when game ends
    func restartGame() {
        score = 0
        lives = 3
        self.newMove()
        timeRemaining = 30
    }
    
    // Checks score and end the game
    func endGame() {
        if score > highscore {
            highscore = score
            scoreTitle = "New high score!"
        } else {
            scoreTitle = "Your score was \(score)"
        }
        gameEnd = true
    }
    
    // Checks to see if the answer is correct
    func optionSelected(_ number: Int) {
        var winMove: Int
        
        // Assigns the right answer to winMove
        if winCondition {
            winMove = (currentMove + 1) % moves.count
        } else {
            winMove = (currentMove + 2) % moves.count
        }

        // If it is the right answer, scores, else, remove life
        number == winMove ? (score += 1) : (lives -= 1)
        
        // Check to see if the game ended
        if lives > 0 {
            self.newMove()
        } else {
            self.endGame()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
