//
//  NumericArithmeticType.swift
//  Dimensional
//
//  Created by Jaden Geller on 1/6/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//  Modified by John Howell on 12/30/2016. - Added scalar addition and subtraction.
//  Modified by Vladislav Lisyanskiy on 9/10/2017. - Converted to Swift 4.
//

public protocol NumericArithmetic: ExpressibleByIntegerLiteral {
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    
    static func +=(lhs: inout Self, rhs: Self)
    static func -=(lhs: inout Self, rhs: Self)
    static func *=(lhs: inout Self, rhs: Self)
    static func /=(lhs: inout Self, rhs: Self)
}


public protocol SignedNumericArithmetic: NumericArithmetic {
    prefix static func -(value: Self) -> Self
}

public protocol FloatingPointArithmetic: SignedNumericArithmetic, FloatingPoint { }

extension Int8   : SignedNumericArithmetic { }
extension Int16  : SignedNumericArithmetic { }
extension Int32  : SignedNumericArithmetic { }
extension Int64  : SignedNumericArithmetic { }
extension Int    : SignedNumericArithmetic { }
extension UInt8  : NumericArithmetic { }
extension UInt16 : NumericArithmetic { }
extension UInt32 : NumericArithmetic { }
extension UInt64 : NumericArithmetic { }
extension UInt   : NumericArithmetic { }
extension Float32 : FloatingPointArithmetic { }
extension Float64 : FloatingPointArithmetic { }
#if arch(x86_64) || arch(i386)
    extension Float80 : FloatingPointArithmetic { }
#endif

public prefix func -<T: SignedNumericArithmetic>(value: Matrix<T>) -> Matrix<T> {
    return value.map {-$0}
}

public func *<T: NumericArithmetic>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
    return rhs.map { lhs * $0 }
}

public func *<T: NumericArithmetic>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    return lhs.map { rhs * $0 }
}

public func +<T: NumericArithmetic>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
    return rhs.map { lhs + $0 }
}

public func +<T: NumericArithmetic>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    return lhs.map { rhs + $0 }
}

public func -<T: NumericArithmetic>(lhs: T, rhs: Matrix<T>) -> Matrix<T> {
    return rhs.map { lhs - $0 }
}

public func -<T: NumericArithmetic>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    return lhs.map { $0 - rhs}
}

public func /<T: NumericArithmetic>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
    return lhs.map { $0 / rhs}
}

public func +<T: NumericArithmetic>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    precondition(lhs.dimensions == rhs.dimensions, "Cannot add matrices of different dimensions.")
    return lhs.zipWith(rhs, transform: +)
}

public func -<T: NumericArithmetic>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    precondition(lhs.dimensions == rhs.dimensions, "Cannot subract matrices of different dimensions.")
    return lhs.zipWith(rhs, transform: -)
}

public func +=<T: NumericArithmetic>(lhs: inout Matrix<T>, rhs: Matrix<T>) {
    lhs =  lhs + rhs
}

public func -=<T: NumericArithmetic>(lhs: inout Matrix<T>, rhs: Matrix<T>) {
    lhs =  lhs - rhs
}

public func *=<T: NumericArithmetic>(lhs: inout Matrix<T>, rhs: Matrix<T>) {
    lhs =  lhs * rhs
}

public func *<T: FloatingPointArithmetic>(lhs: Array<T>, rhs: Matrix<T>) -> Array<T> {
    precondition(lhs.count == rhs.rows.count, "Matrix and Vector dimensions are not compatible")
    var result = Array<T>()
    for column in rhs.columns {
        result.append(lhs.dot(column))
    }
    return result
}

public func *<T: FloatingPointArithmetic>(lhs: Matrix<T>, rhs: Array<T>) -> Array<T> {
    precondition(rhs.count == lhs.columns.count, "Matrix and Vector dimensions are not compatible")
    var result = Array<T>()
    for row in lhs.rows {
        result.append(rhs.dot(row))
    }
    return result
}

extension Matrix where Member: NumericArithmetic {
    public func dot(_ other: Matrix<Member>) -> Member {
        precondition(dimensions == other.dimensions, "Cannot take the dot product of matrices of different dimensions.")
        return zipWith(other, transform: *).reduce(0, +)
    }
}

extension Matrix where Member: SignedNumericArithmetic {
    public var determinant: Member {
        precondition(isSquare, "Cannot find the determinant of a non-square matrix.")
        precondition(!isEmpty, "Cannot find the determinant of an empty matrix.")
    
        guard count != 1 else { return self[0, 0] } // Base case

        // Recursive case
        var sum: Member = 0
        var polarity: Member = 1
        
        let topRow = rows[0]
        for (column, value) in topRow.enumerated() {
            var subMatrix = self
            subMatrix.rows.removeFirst()
            subMatrix.columns.remove(at: column)
            sum += polarity * value * subMatrix.determinant
            
            polarity *= -1
        }
        
        return sum
    }

    public var cofactor: Matrix {
        return map { (value, row, column) in
            var subMatrix = self
            subMatrix.rows.remove(at: row)
            subMatrix.columns.remove(at: column)
            let polarity: Member = ((row + column) % 2 == 0 ? 1 : -1)
            return subMatrix.determinant * polarity
        }
    }
    
    public var adjoint: Matrix {
        return cofactor.transposed
    }
}

extension Matrix where Member: FloatingPointArithmetic {
    public var cholesky:Matrix {
        /* Ported from LAPACK Fortran Code http://www.netlib.org/lapack/double/dpotrf.f */
        precondition(!isEmpty, "Cannot find the cholesky of an empty matrix.")
        precondition(self.isSquare, "Cannot find the cholesky of a non-square matrix.") //Matrix must be square
        //precondition(self.isSymmetric, "Cannot find the cholesky of a nonsymmetric matrix.")
        
        
        let n = rows.count
        
        
        var temp: Matrix = Matrix(repeating: 0, dimensions: (n, n))
        for i in 0..<n {
            for j in i..<n {
                temp[i,j] = self[i,j]
            }
        }
        
        temp[0,0] = temp[0,0].squareRoot()
        for j in 1..<n {
            temp[0,j] = temp[0,j]/temp[0,0]
        }
        
        for j in 1..<n {
            temp[j,j] -= (0..<j).map{temp[$0, j] * temp[$0, j]}.reduce(0, +) //Dot Product
            temp[j,j].formSquareRoot()

            for loop1 in (j+1)..<n {
                temp[j, loop1] += (0..<j).map{ -1 * temp[$0, j] * temp[$0, loop1]}.reduce(0, +) // y = -A'x + y
                temp[j, loop1] = temp[j,loop1]/temp[j,j]
            }
        }
        
        return temp
    }
}

extension Matrix where Member: FloatingPointArithmetic {
    public var inverse: Matrix {
        return adjoint * (1 / determinant)
    }
}

extension Matrix where Member: NumericArithmetic {
    public func transformVector(_ vector: [Member]) -> [Member] {
        return rows.map{ row in zip(row, vector).map(*).reduce(0, +) }
    }
}

public func *<T: NumericArithmetic>(lhs: Matrix<T>, rhs: Matrix<T>) -> Matrix<T> {
    precondition(lhs.columns.count == rhs.rows.count, "Incompatible dimensions for matrix multiplication.")
    return Matrix(lhs.rows.map(rhs.transposed.transformVector))
}

