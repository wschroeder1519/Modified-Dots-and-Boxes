//
//  Successor.swift
//  Modified Dots and Boxes
//
//  Created by William Schroeder.
//  Copyright © 2019 William Schroeder. All rights reserved.
//

import Foundation

class DBSuccessor {
    
    static func getSuccessors(of parent: GameState) -> [GameState] {
    
        var resList: [GameState] = []
        let board = parent.getBoard()
        
        for i in 1..<board.count {
        
            if parent.moveIsValid(at: i) {
                
                let child = GameState(from: parent, at: i, on: board)
                child.doMove(at: i)
                resList.append(child);
            }
        }
        
        return resList
    }
}
