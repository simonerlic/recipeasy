//
//  Item.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-11-16.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
