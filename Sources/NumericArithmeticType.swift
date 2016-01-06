//
//  NumericArithmeticType.swift
//  Dimensional
//
//  Created by Jaden Geller on 1/6/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public protocol NumericArithmeticType: IntegerLiteralConvertible {
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
    
    func +=(inout lhs: Self, rhs: Self)
    func -=(inout lhs: Self, rhs: Self)
    func *=(inout lhs: Self, rhs: Self)
    func /=(inout lhs: Self, rhs: Self)
}

public protocol SignedNumericArithmeticType: NumericArithmeticType {
    prefix func -(value: Self) -> Self
}

public protocol FloatingPointArithmeticType: SignedNumericArithmeticType { }

extension Int8   : SignedNumericArithmeticType { }
extension Int16  : SignedNumericArithmeticType { }
extension Int32  : SignedNumericArithmeticType { }
extension Int64  : SignedNumericArithmeticType { }
extension Int    : SignedNumericArithmeticType { }
extension UInt8  : NumericArithmeticType { }
extension UInt16 : NumericArithmeticType { }
extension UInt32 : NumericArithmeticType { }
extension UInt64 : NumericArithmeticType { }
extension UInt   : NumericArithmeticType { }
extension Float32 : FloatingPointArithmeticType { }
extension Float64 : FloatingPointArithmeticType { }
extension Float80 : FloatingPointArithmeticType { }

public prefix func -<T: SignedNumericArithmeticType>(value: Matrix<T>) -> Matrix<T> {
    return value.map(-)
}

public func *<T: NumericArithmeticType>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
    return rhs.map { lhs * $0 }
}

public func *<T: NumericArithmeticType>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    return lhs.map { rhs * $0 }
}

public func +<T: NumericArithmeticType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    precondition(lhs.dimensions == rhs.dimensions, "Cannot add matrices of different dimensions.")
    return lhs.zipWith(rhs, transform: +)
}

public func -<T: NumericArithmeticType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    precondition(lhs.dimensions == rhs.dimensions, "Cannot subract matrices of different dimensions.")
    return lhs.zipWith(rhs, transform: -)
}

extension Matrix where Member: NumericArithmeticType {
    public func dot(other: Matrix<Member>) -> Member {
        precondition(dimensions == other.dimensions, "Cannot take the dot product of matrices of different dimensions.")
        return zipWith(other, transform: *).reduce(0, combine: +)
    }
}

extension Matrix where Member: SignedNumericArithmeticType {
    public var determinant: Member {
        precondition(isSquare, "Cannot find the determinant of a non-square matrix.")
        precondition(!isEmpty, "Cannot find the determinant of an empty matrix.")
    
        guard count != 1 else { return self[row: 0, column: 0] } // Base case

        // Recursive case
        var sum: Member = 0
        var polarity: Member = 1
        
        let topRow = rows[0]
        for (column, value) in topRow.enumerate() {
            var subMatrix = self
            subMatrix.rows.removeFirst()
            subMatrix.columns.removeAtIndex(column)
            sum += polarity * value * subMatrix.determinant
            
            polarity *= -1
        }
        
        return sum
    }

    public var cofactor: Matrix {
        return map { (value, row, column) in
            var subMatrix = self
            subMatrix.rows.removeAtIndex(row)
            subMatrix.columns.removeAtIndex(column)
            let polarity: Member = ((row + column) % 2 == 0 ? 1 : -1)
            return subMatrix.determinant * polarity
        }
    }
    
    public var adjoint: Matrix {
        return cofactor.transpose
    }
}

extension Matrix where Member: FloatingPointArithmeticType {
    public var inverse: Matrix {
        return adjoint * (1 / determinant)
    }
}

extension Matrix where Member: NumericArithmeticType {
    public func transformVector(vector: [Member]) -> [Member] {
        return rows.map{ row in zip(row, vector).map(*).reduce(0, combine: +) }
    }
}

public func *<T: NumericArithmeticType>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    precondition(lhs.columns.count == rhs.rows.count, "Incompatible dimensions for matrix multiplication.")
    return Matrix(lhs.rows.map(rhs.transpose.transformVector))
}

