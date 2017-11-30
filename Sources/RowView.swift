//
//  RowView.swift
//  Dimensional
//
//  Created by Jaden Geller on 1/5/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//  Modified by Vladislav Lisyanskiy on 9/10/2017. - Converted to Swift 4.
//

public struct RowView<Member> {
    internal var matrix: Matrix<Member>
    
    internal init(matrix: Matrix<Member>) {
        self.matrix = matrix
    }
}

extension RowView: ExpressibleByArrayLiteral {
    public init() {
        self.matrix = Matrix()
    }
    
    public init<S: Sequence>(_ rows: S) where S.Iterator.Element == [Member] {
        self.init()
        append(contentsOf: rows)
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

extension RowView: MutableCollection, RangeReplaceableCollection {
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == [Member] {
        let expectedCount = matrix.count > 0 ? matrix.columns.count : (newElements.first?.count ?? 0)
        newElements.forEach { row in
            precondition(row.count == expectedCount, "Incompatable vector size.")
        }
        matrix.rowBacking.replaceSubrange(subRange, with: newElements)
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return matrix.rowBacking.count
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
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
