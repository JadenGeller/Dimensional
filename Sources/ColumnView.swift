//
//  ColumnView.swift
//  Dimensional
//
//  Created by Jaden Geller on 1/5/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct ColumnView<Member> {
    internal var matrix: Matrix<Member>
    
    internal init(matrix: Matrix<Member>) {
        self.matrix = matrix
    }
}

extension ColumnView: ExpressibleByArrayLiteral {
    public init() {
        self.matrix = Matrix()
    }
    
    public init<S: Sequence>(_ columns: S) where S.Iterator.Element == [Member] {
        self.init()
        append(contentsOf: columns)
    }
    
    public init(arrayLiteral elements: [Member]...) {
        self.init(elements)
    }
}

extension ColumnView: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return Array(self).description
    }
    
    public var debugDescription: String {
        return Array(self).debugDescription
    }
}

extension ColumnView: MutableCollection, RangeReplaceableCollection {
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == [Member] {
        
        // Verify size
        let expectedCount = matrix.count > 0 ? matrix.rows.count : (newElements.first?.count ?? 0)
        newElements.forEach { column in
            precondition(column.count == expectedCount, "Incompatable vector size.")
        }
        if matrix.count == 0 { matrix.rowBacking = Array(repeating: Array(), count: expectedCount) }
        
        // Replace range
        matrix.rowBacking.indices.forEach { index in
            matrix.rowBacking[index].replaceSubrange(subRange, with: newElements.map { column in
                column[index]
            })
        }
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return matrix.rowBacking.first?.count ?? 0
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public subscript(index: Int) -> [Member] {
        get {
            return matrix.rows.indices.map{ i in matrix[i, index] }
        }
        set {
            precondition(newValue.count == matrix.rows.count, "Incompatible vector size.")
            zip(matrix.rows.indices, newValue).forEach { (i, v) in matrix[i, index] = v }
        }
    }
}
