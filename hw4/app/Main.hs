import System.Random.Shuffle (shuffle')
import System.Random (StdGen, randomRs, newStdGen)
-- data type for cards
data Cards = A | Two | Three | Four | Five | Six | Seven | Eight | Nine | Ten | J | Q | K 
    deriving(Show, Enum, Eq, Bounded, Read)

-- equivalences for scores 
getCardScore :: Cards -> Int 
getCardScore x = case x of
    A -> 1
    Two -> 2
    Three -> 3
    Four -> 4
    Five -> 5
    Six -> 6
    Seven -> 7
    Eight -> 8
    Nine -> 9
    Ten -> 10
    J -> 10
    Q -> 10
    K -> 10

-- data type for a game state
data GameState = GameState{
    deck :: [Cards],
    playerCards :: [Cards],
    dealerCards :: [Cards]
} deriving(Show)

-- helper for getting number of aces 
hasAces :: [Cards] -> Bool
hasAces x = elem A x
-- a helper function for giving us a deck with several of each card type
genDeck :: [a] -> Int -> [a]

genDeck xs n = xs >>= replicate n

-- hit function will take a gamestate and a selected player and output a new game state where that player has hit
hit :: GameState -> Int -> GameState

-- player 0 is the agent, player 1 is the dealer
hit inState player = GameState{
    deck = tail(deck inState),
    playerCards = if player == 1 then playerCards inState else head (deck inState) : playerCards inState,
    dealerCards = if player == 1 then head (deck inState) : dealerCards inState else dealerCards inState
}
--sets up the starting state of the game
-- need to add the initial draws of cards for player
setup :: StdGen -> GameState

setup gen = let availableCards = [A, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, J, Q, K]
        in let newDeck = genDeck availableCards 4
        in let n = length newDeck
        in let randomDeck = shuffle' newDeck n gen
        in let temp = GameState{deck = randomDeck, playerCards = [],dealerCards = []}
        in hit (hit temp 0) 0 -- we're hitting the player twice to start game.

-- One player score
onePScore :: [Cards] -> Int
onePScore hand = let x = foldr (\a b -> getCardScore a + b) 0 hand in if x <=11 && hasAces hand then x + 9 else x
-- return the scores for (Player, Dealer)
score :: GameState -> (Int, Int)
score state = (onePScore(playerCards state), onePScore(dealerCards state))

main :: IO ()
main = do
    gen <- newStdGen
    let currentState = setup gen
    print(dealerCards currentState)
    print(playerCards currentState)
    print(deck currentState)
    print(score currentState)
    let nextState = hit currentState 0 
    print(playerCards nextState)
    print(score nextState)
