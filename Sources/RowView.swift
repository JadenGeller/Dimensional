//
//  RowView.swift
//  Dimensional
//
//  Created by Jaden Geller on 1/5/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct RowView<Member> {
    internal var matrix: Matrix<Member>
    
    internal init(matrix: Matrix<Member>) {
        self.matrix = matrix
    }
}

extension RowView: ArrayLiteralConvertible {
    public init() {
        self.matrix = Matrix()
    }
    
    public init<S: SequenceType where S.Generator.Element == [Member]>(_ rows: S) {
        self.init()
        appendContentsOf(rows)
    }
    
    public init(arrayLiteral elements: [Member]...) {
        self.init(elements)
    }
}

extension RowView: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return Array(self).description
    }
    
    public var debugDescription: String {
        return Array(self).debugDescription
    }
}

extension RowView: MutableCollectionType, RangeReplaceableCollectionType {
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == [Member]>(subRange: Range<Int>, with newElements: C) {
        let expectedCount = matrix.count > 0 ? matrix.columns.count : (newElements.first?.count ?? 0)
        newElements.forEach{ row in
            precondition(row.count == expectedCount, "Incompatable vector size.")
        }
        matrix.rowBacking.replaceRange(subRange, with: newElements)
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return matrix.rowBacking.count
    }
    
    public subscript(index: Int) -> [Member] {
        get {
            return matrix.rowBacking[index]
        }
        set {
            precondition(newValue.count == matrix.columns.count, "Incompatible vector size.")
            matrix.rowBacking[index] = newValue
        }
    }
}

