//
//  Matrix.swift
//  Dimensional
//
//  Created by Jaden Geller on 1/5/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct Matrix<Member> {
    internal var rowBacking: [[Member]]
}

extension Matrix: ExpressibleByArrayLiteral {
    public init() {
        self.rowBacking = []
    }
    
    public init(_ rows: [[Member]]) {
        self.init(RowView(rows))
    }
    
    public init(arrayLiteral elements: [Member]...) {
        self.init(elements)
    }
    
    public init(_ rows: RowView<Member>) {
        self.rowBacking = rows.matrix.rowBacking
    }
    
    public init(_ columns: ColumnView<Member>) {
        self.rowBacking = columns.matrix.rowBacking
    }
}

extension Matrix {
    public subscript(row: Int, column: Int) -> Member {
        get {
            return rowBacking[row][column]
        }
        set {
            rowBacking[row][column] = newValue
        }
    }
    
    public var rows: RowView<Member> {
        get {
            return RowView(matrix: self)
        }
        set {
            self = Matrix(newValue)
        }
    }
    
    public var columns: ColumnView<Member> {
        get {
            return ColumnView(matrix: self)
        }
        set {
            self = Matrix(newValue)
        }
    }
}

extension Matrix: Collection {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return rows.count * columns.count
    }
    
    public func positionWithIndex(_ index: Int) -> (row: Int, column: Int) {
        return (row: index / columns.count, column: index % columns.count)
    }
    
    public subscript(index: Int) -> Member {
        get {
            let position = positionWithIndex(index)
            return self[position.row, position.column]
        }
        set {
            let position = positionWithIndex(index)
            self[position.row, position.column] = newValue
        }
    }
}

extension Matrix: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return rows.description
    }
    
    public var debugDescription: String {
        return rows.debugDescription
    }
}

public func ==<Member: Equatable>(lhs: Matrix<Member>, rhs: Matrix<Member>) -> Bool {
    return lhs.rowBacking.count == rhs.rowBacking.count && zip(lhs.rowBacking, rhs.rowBacking).reduce(true) { result, pair in result && pair.0 == pair.1 }
}

extension Matrix {
    public func map<T>(transform: (Member) throws -> T) rethrows -> Matrix<T> {
        return Matrix<T>(RowView(try rows.map{ try $0.map(transform) }))
    }
    
    public func map<T>(transform: @escaping (Member, _ row: Int, _ column: Int) throws -> T) rethrows -> Matrix<T> {
        return Matrix<T>(RowView(try rows.enumerated().map{ (r, columns) in
            try columns.enumerated().map{ (c, value) in
                try transform(value, r, c)
            }
        }))
    }
    
    public func zipWith<U, V>(_ matrix: Matrix<U>, transform: @escaping (Member, U) -> V) -> Matrix<V> {
        return Matrix<V>(RowView(zip(self.rows, matrix.rows).map{ zip($0, $1).map(transform) }))
    }
}

extension Matrix {
    public var isSquare: Bool {
        return rows.count == columns.count
    }
    
    public var transpose: Matrix {
        return Matrix(RowView(columns))
    }
}

extension Matrix where Member: ExpressibleByIntegerLiteral {
    public static func diagonal(_ dimensions: MatrixDimensions, diagonalValue: Member, defaultValue: Member) -> Matrix {
        var matrix = Matrix(dimensions: dimensions, repeatedValue: defaultValue)
        for i in 0..<Swift.min(dimensions.width, dimensions.height) {
            matrix[i, i] = diagonalValue
        }
        return matrix
    }
    
    public static func diagonal(_ dimensions: MatrixDimensions) -> Matrix {
        return diagonal(dimensions, diagonalValue: 1, defaultValue: 0)
    }
    
    public static func identity(size: Int) -> Matrix {
        return diagonal((size, size))
    }
}

public typealias MatrixDimensions = (width: Int, height: Int)

extension Matrix {
    public init(dimensions: MatrixDimensions, repeatedValue: Member) {
        self.rowBacking = Array(repeating: Array(repeating: repeatedValue, count: dimensions.width), count: dimensions.height
        )
    }
    
    public var dimensions: MatrixDimensions {
        return (width: columns.count, height: rows.count)
    }
}

public func ==(lhs: MatrixDimensions, rhs: MatrixDimensions) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}







