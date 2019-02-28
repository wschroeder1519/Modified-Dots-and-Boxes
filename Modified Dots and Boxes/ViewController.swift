//
//  ViewController.swift
//  Modified Dots and Boxes
//
//  Created by William Schroeder.
//  Copyright © 2019 William Schroeder. All rights reserved.
//
//  A modified version of the classic game, Dots and Boxes.
//
//  The algorithm is "skilled" enough to challenge a player,
//  but the player does have a chance of success against the bot.
//
//  Early-game efficiency could be improved, as the algoritm was
//  originally designed for use on a desktop or laptop computer.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var screenBoard: UILabel!
    @IBOutlet weak var rowEntry: UITextField!
    @IBOutlet weak var columnEntry: UITextField!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var playerPoints: UILabel!
    @IBOutlet weak var botPoints: UILabel!
    
    var game: GameState = GameState(size: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowEntry.text = nil
        columnEntry.text = nil
        screenBoard.text = game.print()
    }
    
    @IBAction func backgroundTouched(_ sender: UIControl) {
        
        for tf in textFields{
            tf.resignFirstResponder()
        }
    }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        
        // Before reset, ask user if certain
        let title = "Restart Board"
        let message = "The current game will be lost. Do you really wish to restart?"
        let restartAlert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Restart", style: .destructive) { _ in self.restartHelper() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        restartAlert.addAction(confirmAction)
        restartAlert.addAction(cancelAction)
        self.present(restartAlert, animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
    
        if let row = rowEntry.text, let col = columnEntry.text {
            
            if let rowNum = Int(row), let colNum = Int(col) {
            
                rowEntry.text = nil
                columnEntry.text = nil
            
                let index = self.findIndex(row: rowNum, column: colNum, width: game.getNumElements())
            
                if game.moveIsValid(at: index) {
                    
                    // Perform the player's move
                    game.doMove(at: index)
                    self.updateScreen()
                    
                    // Perform the bot's move
                    Search.search(game, depth: 2)
                    game.doMove(at: game.getBestMove())
                    
                    // Declare winner and restart board
                    if game.gameIsComplete() {
                        
                        let endTitle = "Game Over!"
                        let endMessage = game.printWinner()

                        let thinkingAlert = UIAlertController(title: endTitle, message: endMessage, preferredStyle: .alert)
                        let newGameAction = UIAlertAction(title: "Play Again", style: .default) { _ in
                            self.restartHelper()
                        }
                        thinkingAlert.addAction(newGameAction)
                        self.present(thinkingAlert, animated: true, completion: nil)
                        
                    } else {
                        
                        // Bot has moved alert
                        let tTitle = "Bot Move"
                        let tMessage = "The bot has taken its turn!"
                        let thinkingAlert = UIAlertController(title: tTitle, message: tMessage, preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        thinkingAlert.addAction(okayAction)
                        self.present(thinkingAlert, animated: true, completion: nil)
                        
                        self.updateScreen()
                    }
                    
                } else {
                    
                    // Error: Selected move could not be indexed, or it was already performed
                    let iTitle = "Invalid Move"
                    let iMessage = "The move you have entered is invalid. Please enter a different move."
                    let invalidAlert = UIAlertController(title: iTitle, message: iMessage, preferredStyle: .actionSheet)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    invalidAlert.addAction(okayAction)
                    self.present(invalidAlert, animated: true, completion: nil)
                }
            }
            
        } else {
            
            // Error: One or more fields left empty
            let fTitle = "Empty Fields"
            let fMessage = "You must select data for both row and column. Please enter both values and try again."
            let fieldAlert = UIAlertController(title: fTitle, message: fMessage, preferredStyle: .actionSheet)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            fieldAlert.addAction(okayAction)
            self.present(fieldAlert, animated: true, completion: nil)
        }
    }
    
    // Set values according to Integer index of array
    func findIndex(row: Int, column: Int, width rowSize: Int) -> Int {
    
        // Ensure row/column size not exceeded
        if row > game.getNumElements() || column > game.getNumElements() {
            return -1
        }
        
        let nRow = row - 1
        let nColumn = column - 1
    
        let res = nColumn + (nRow * rowSize);
    
        return res;
    }
    
    // Restart the game state
    func restartHelper() {

        game = GameState(size: 4)
        self.updateScreen()
    }
    
    // Update all screen elements
    func updateScreen() {
        
        rowEntry.text = nil
        columnEntry.text = nil
        screenBoard.text = game.print()
        playerPoints.text = "\(game.getPlayerScore())"
        botPoints.text = "\(game.getBotScore())"
    }
}
