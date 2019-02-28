//
//  Search.swift
//  Modified Dots and Boxes
//
//  Created by William Schroeder.
//  Copyright © 2019 William Schroeder. All rights reserved.
//

import Foundation

class Search {
    
    // Minimax search algorithm for the dots and boxes game
    static func search(_ game: GameState, depth ply: Int) {
        
        if game.getDepth() == ply * 2 || game.gameIsComplete() {
            
            game.score()
            
        } else {
        
            let stateArr = DBSuccessor.getSuccessors(of: game)
            
            for gs in stateArr {
            
                // Search recursively until leaf values are reached
                search(gs, depth: ply)
                
                // Propagate values up as necessary
                if let currScore = game.getScore() {
                    if (!game.getTurn() && currScore < gs.getScore()!)
                        || (game.getTurn() && currScore > gs.getScore()!) {
                    
                        game.updateBotMove(to: gs)
                        
                    } else if (!game.getTurn() && currScore == gs.getScore()!)
                        || (game.getTurn() && currScore == gs.getScore()!) {
                     
                        // Allow the bot to make semi-random choices
                        let toss = Int.random(in: 0 ... 9)
                        
                        if toss == 0 {
                            
                            game.updateBotMove(to: gs)
                        }
                    }
                    
                } else {
                    
                    game.updateBotMove(to: gs)
                }
            }
        }
    }
}
