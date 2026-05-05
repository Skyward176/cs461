import System.Random.Shuffle (shuffle')
import System.Random (StdGen, randomRs, newStdGen)
import System.IO
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
    dealerCards :: [Cards],
    playerStay :: Bool
} deriving(Show)

-- helper for getting number of aces 
hasAces :: [Cards] -> Bool
hasAces = elem A
-- a helper function for giving us a deck with several of each card type
genDeck :: [a] -> Int -> [a]

genDeck xs n = xs >>= replicate n

-- hit function will take a gamestate and a selected player and output a new game state where that player has hit
hit :: GameState -> Int -> GameState

-- player 0 is the agent, player 1 is the dealer
hit inState player = GameState{
    deck = tail(deck inState),
    playerCards = if player == 1 then playerCards inState else head (deck inState) : playerCards inState,
    dealerCards = if player == 1 then head (deck inState) : dealerCards inState else dealerCards inState,
    playerStay = False
}
--sets up the starting state of the game
-- need to add the initial draws of cards for player
setup :: StdGen -> GameState

setup gen = let availableCards = [A, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, J, Q, K]
        in let newDeck = genDeck availableCards 4
        in let n = length newDeck
        in let randomDeck = shuffle' newDeck n gen
        in let temp = GameState{deck = randomDeck, playerCards = [],dealerCards = [], playerStay = False}
        in hit (hit temp 0) 0 -- we're hitting the player twice to start game.

-- One player score
onePScore :: [Cards] -> Int
onePScore hand = let x = foldr (\a b -> getCardScore a + b) 0 hand in if x <=11 && hasAces hand then x + 9 else x
-- return the scores for (Player, Dealer)
score :: GameState -> (Int, Int)
score state = (onePScore(playerCards state), onePScore(dealerCards state))

-- print a prompt
statePrompt :: GameState -> IO ()
statePrompt state = do
    print (playerCards state)
    print (score state) 

-- check if the game is over
checkStatus :: GameState -> String
checkStatus state
    | playerScore > 21 = "Bust"
    | dealerScore >= 17 = 
        if dealerScore > 21 || playerScore > dealerScore then
            "win"
        else
            "lose"
    | otherwise = "in play"
    where (playerScore, dealerScore) = score state

runIO :: GameState -> IO GameState
runIO state = do
    _ <- statePrompt state
    action <- waitForInput
    if action == "h" then
        return(hit state 0)
    else
        return(GameState{
            deck = deck state,
            playerCards = playerCards state,
            dealerCards = dealerCards state,
            playerStay = True
        })
-- game loop
gameLoop :: GameState -> IO GameState
gameLoop state = do 
    let status = checkStatus state
    if not (playerStay state) && status == "in play" then do
        nextState <- runIO state 
        gameLoop nextState
    else do
        let dealerState = initDealer state
        runDealerLoop dealerState
-- init dealer turn
initDealer :: GameState -> GameState
initDealer state = do
    hit (hit state 1) 1 -- we're hitting the player twice to start game.

runDealerLoop :: GameState -> IO GameState
runDealerLoop state = do
    let status = checkStatus state
    if status == "in play" then do
        let nextState = hit state 1
        runDealerLoop nextState
    else do
        return state 
-- get input
waitForInput :: IO String

waitForInput = do 
    putStrLn "Input (h) to hit or (s) to stay: " 
    hFlush stdout    
    getLine


main :: IO ()
main = do
    gen <- newStdGen
    let state = setup gen
    cur <- gameLoop state
    let finalScore =  score cur
    print "final score:" 
    print finalScore
    print( playerCards cur)
    print( dealerCards cur)
    print (checkStatus cur)
