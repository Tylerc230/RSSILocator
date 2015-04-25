//
//  Matrix.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/21/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
class Matrix<T> {
    let data:NSMutableData
    let columns:Int
    let rows:Int
    private let buffer:UnsafeMutablePointer<T>
    init(rows:Int, columns:Int) {
        self.rows = rows
        self.columns = columns
        let bufferSize = rows * columns * sizeof(T)
        data = NSMutableData(length: bufferSize)!
        buffer = UnsafeMutablePointer<T>(data.bytes)
    }
    
    subscript(row:Int, column:Int) -> T {
        get {
            return buffer[row * columns + column]
        }
        
        set {
            buffer[row * columns + column] = newValue
        }
    }
}
