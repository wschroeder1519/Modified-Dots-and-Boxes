//
//  GameState.swift
//  Modified Dots and Boxes
//
//  Created by William Schroeder.
//  Copyright © 2019 William Schroeder. All rights reserved.
//

import Foundation

class GameState {
    
    private var _score: Int?
    private var _bestMove: Int    // The "best" move from current state
    private var _lastMove: Int   // The move taken to reach this state
    private var _playerScore: Int
    private var _botScore: Int
    private var _depth: Int
    private var _size: Int
    private var _numElements: Int
    private var _moves: Int
    private var _playerTurn: Bool
    private var _board: [String]
    
    
    // The constructor for a board before any moves have been made
    init(size: Int) {
        
        self._score = nil
        self._bestMove = -1
        self._lastMove = -1
        self._playerScore = 0
        self._botScore = 0
        self._depth = 0
        self._size = size
        self._numElements = 2 * _size + 1
        self._moves = 2 * _size * (_size + 1)
        self._playerTurn = true
        
        // Set up a fresh board of size X size dots
        self._board = []
        
        for i in 0..<(_numElements * _numElements) {
            
            if ( i % 2 == 0 ) && ( i % (2 * _numElements) < _numElements ) {
                
                _board.append("*")
                
            } else if ( i % 2 == 0 ) && ( i % (2 * _numElements) >= _numElements ) {
                
                let points = Int.random(in: 1 ... 9)
                _board.append("\(points)")
                
            } else {
                
                _board.append(" ")
            }
        }
    }
    
    // The constructor for the successor function
    init(from parent: GameState, at linePlacedAt: Int, on board: [String]) {
        
        self._score = nil
        self._bestMove = -1
        self._lastMove = linePlacedAt
        self._playerScore = parent.getPlayerScore()
        self._botScore = parent.getBotScore()
        self._depth = parent.getDepth() + 1
        self._size = parent.getSize()
        self._numElements = 2 * self._size + 1
        self._moves = parent.getMoves()
        self._playerTurn = parent.getTurn()
        self._board = board
    }
    
    // Tallies up the scores of each player and returns the
    // int difference between them
    func score() {
        
        _playerScore = 0
        _botScore = 0
    
        for i in 1..<_board.count {
    
            let flag = _board[i]
    
            if flag == "p" {
            _playerScore += Int(_board[i + 1])!
            }
            else if (flag == "b") {
            _botScore += Int(_board[i + 1])!
            }
        }
    
        _score = _botScore - _playerScore
    }
    
    // Propagates the score and "best" move upward from the "best" child
    func updateBotMove(to game: GameState) {
    
        self._bestMove = game.getLastMove()
        self._score = game.getScore()
    }
    
    // Places a line at the indicated index
    // Returns true if successful
    func doMove(at index: Int) {
    
        // Check if in even row, else in odd row - even rows have dots, odd rows have scores
        if (index % (2 * _numElements) < _numElements) {
            _board[index] = "-"
        }
        else {
            _board[index] = "|"
        }
        
        self.checkBoxes(around: index)
        _moves -= 1
        _lastMove = index
        self.score()
        _score = nil
        _playerTurn = !_playerTurn
    }
    
    // Determines which boxes a move may have completed
    // i.e. left/right for '|' and up/down for '-'
    // Calls to setFlag to check if box was completed
    func checkBoxes(around i: Int) {

        let up: Int?    = i - _numElements
        let down: Int?  = i + _numElements
        let left: Int?  = i - 1
        let right: Int? = i + 1
        
        // Check if in even row, else in odd row - even rows complete up/down, odd rows complete left/right
        if (i % (2 * _numElements) < _numElements) {
            
            // Is there a value above?
            if up != nil && up! > 0 {
                
                self.setFlag(at: up!)
            }
            
            // Is there a value below?
            if down != nil && down! < _board.count {
                
                self.setFlag(at: down!)
            }
            
        } else {
        
            // Is there a value to the left?
            if (i % _numElements != 0) {
                
                self.setFlag(at: left!)
            }
            
            // Is there a value to the right?
            if (i % _numElements != (_numElements - 1)) {
                
                self.setFlag(at: right!)
            }
        }
    }
    
    // Helper function for the checkBoxes() method
    // Sets a flag before each of the point values if a box was made
    private func setFlag(at index: Int) {
    
        let sideBound = "p|b"
        
        if _board[index - _numElements] == "-" && _board[index + _numElements] == "-"
        && sideBound.contains(_board[index - 1]) && sideBound.contains(_board[index + 1]) {
            
            if _playerTurn {
                
                _board[index - 1] = "p"
                
            } else {
                
                _board[index - 1] = "b"
            }
        }
    }
    
    // Returns true if there are no valid moves left on the board
    func gameIsComplete() -> Bool {
    
        if _moves == 0 {
            return true
        }
    
        return false
    }
    
    // Returns true if the array index is a valid move space
    func moveIsValid(at index: Int) -> Bool {
    
        if index >= _board.count {
            return false
        } else if index < 0 {
            return false
        } else if (_board[index] != " ") {
            return false
        }
        
        return true
    }
    
    // Formats the board's internal representation as a string,
    // then prints the result
    func print() -> String {
        
        var boardString = "0"
    
        for i in 1..._numElements {
            
            boardString.append(" \(i)")
        }
    
        for i in 0..<_board.count {
        
            // Begin next row on the board
            if i % _numElements == 0 {
                
                boardString.append("\n\(i / _numElements + 1) ")
            }
        
            // Replace flag characters with '|'
            if _board[i] == "p" || _board[i] == "b" {
                
                boardString.append("| ")
                
            } else {
                
                boardString.append("\(_board[i]) ")
            }
        }
    
        return boardString
    }
    
    // Identifies the winner and prints the result to the screen
    func printWinner() -> String {
        
        var winMsg: String
    
        if (gameIsComplete()) {
    
            self.score()
    
            if (_playerScore > _botScore) {
    
                winMsg = "Congratulations, you win!"
    
            } else {
    
                winMsg = "Sorry, you lose!"
    
            }
    
        } else {
            
            winMsg = "Game is not finished yet!"
        }
        
        return winMsg
    }
    
    // Returns the index of the best move encountered so far
    func getBestMove() -> Int {
        return self._bestMove;
    }
    
    // Returns the index of the move taken to reach this state
    func getLastMove() -> Int {
        return self._lastMove;
    }
    
    // Returns a copy of the score Integer
    func getScore() -> Int? {
        return self._score;
    }
    
    // Returns the human player's score
    func getPlayerScore() -> Int {
        return self._playerScore;
    }
    
    // Returns the bot player's score
    func getBotScore() -> Int {
        return self._botScore;
    }
    
    // Returns the depth of this state from the root
    func getDepth() -> Int{
        return self._depth;
    }
    
    // Returns the size (width) of the board
    func getSize() -> Int {
        return self._size;
    }
    
    // Returns the number of elements in one "row" of the board array
    func getNumElements() -> Int {
        return self._numElements;
    }
    
    // Returns the number of moves remaining in the game
    func getMoves() -> Int {
        return self._moves;
    }
    
    // Returns true on the human player's turn
    func getTurn() -> Bool {
        return self._playerTurn;
    }
    
    // Returns a copy of the board array
    func getBoard() -> [String] {
        return self._board;
    }
}
