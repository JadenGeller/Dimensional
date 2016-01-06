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

extension ColumnView: ArrayLiteralConvertible {
    public init() {
        self.matrix = Matrix()
    }
    
    public init<S: SequenceType where S.Generator.Element == [Member]>(_ columns: S) {
        self.init()
        appendContentsOf(columns)
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

extension ColumnView: MutableCollectionType, RangeReplaceableCollectionType {
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == [Member]>(subRange: Range<Int>, with newElements: C) {
        
        // Verify size
        let expectedCount = matrix.count > 0 ? matrix.rows.count : (newElements.first?.count ?? 0)
        newElements.forEach { column in
            precondition(column.count == expectedCount, "Incompatable vector size.")
        }
        if matrix.count == 0 { matrix.rowBacking = Array(count: expectedCount, repeatedValue: Array()) }
        
        // Replace range
        matrix.rowBacking.indices.forEach { index in
            matrix.rowBacking[index].replaceRange(subRange, with: newElements.map { column in
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
    
    public subscript(index: Int) -> [Member] {
        get {
            return matrix.rows.indices.map{ i in matrix[row: i, column: index] }
        }
        set {
            precondition(newValue.count == matrix.rows.count, "Incompatible vector size.")
            zip(matrix.rows.indices, newValue).forEach { (i, v) in matrix[row: i, column: index] = v }
        }
    }
}
