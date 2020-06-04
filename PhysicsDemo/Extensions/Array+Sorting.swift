//
//  Array+Sorting.swift
//  PhysicsDemo
//
//  Created by Steve Barnegren on 25/02/2020.
//  Copyright © 2020 Steve Barnegren. All rights reserved.
//

import Foundation

// MARK: - Sorted Ascending / Descending

extension Array where Element: Comparable {
    
    public func sortedAscending() -> [Element] {
        return sorted { $0 < $1 }
    }
    
    public func sortedDescending() -> [Element] {
        return sorted { $0 > $1 }
    }
    
    public mutating func sortAscending() {
        sort { $0 < $1 }
    }
    
    public mutating func sortDescending() {
        sort { $0 > $1 }
    }
}

// MARK: - Sorted Ascending / Descending by

extension Array {
    
    public func sortedAscendingBy<T: Comparable>(_ key: (Element) -> T) -> [Element] {
        return sorted { key($0) < key($1) }
    }
    
    public func sortedDescendingBy<T: Comparable>(_ key: (Element) -> T) -> [Element] {
        return sorted { key($0) > key($1) }
    }
    
    public mutating func sortAscendingBy<T: Comparable>(_ key: (Element) -> T) {
        sort { key($0) < key($1) }
    }
    
    public mutating func sortDescendingBy<T: Comparable>(_ key: (Element) -> T) {
        sort { key($0) > key($1) }
    }
}

// MARK: - Bring to front / Send to back

extension Array {
    
    public mutating func bringToFront(_ matches: (Element) -> Bool) {
        
        var indexesToMove = [Int]()
        var itemsToMove = [Element]()
        
        // Find the items that we need to move
        for (index, item) in self.enumerated() {
            if matches(item) {
                indexesToMove.append(index)
                itemsToMove.append(item)
            }
        }
        
        // We remove the last items first, so that the indexes are always in bounds
        for index in indexesToMove.reversed() {
            remove(at: index)
        }
        
        // Insert the items at the front
        // in the reverse order that we found them
        // so that they maintain their original order
        itemsToMove.reversed().forEach {
            insert($0, at: 0)
        }
    }
    
    public mutating func sendToBack(_ matches: (Element) -> Bool) {
        
        var indexesToMove = [Int]()
        var itemsToMove = [Element]()
        
        // Find the items that we need to move
        for (index, item) in self.enumerated() {
            if matches(item) {
                indexesToMove.append(index)
                itemsToMove.append(item)
            }
        }
        
        // We remove the last items first, so that the indexes are always in bounds
        for index in indexesToMove.reversed() {
            remove(at: index)
        }
        
        // Insert the items at the back
        itemsToMove.forEach {
            append($0)
        }
    }
}
