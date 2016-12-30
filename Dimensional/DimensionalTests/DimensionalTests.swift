//
//  DimensionalTests.swift
//  DimensionalTests
//
//  Created by Jaden Geller on 1/5/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Dimensional

class DimensionalTests: XCTestCase {
    
    func testRowsColumns() {
        let matrix: Matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        XCTAssertEqual([[1, 2, 3], [4, 5, 6], [7, 8, 9]].flatMap{ $0 }, Array(matrix.rows).flatMap{ $0 })
        XCTAssertEqual([[1, 4, 7], [2, 5, 8], [3, 6, 9]].flatMap{ $0 }, Array(matrix.columns).flatMap{ $0 })
    }
    
    func testAppending() {
        var matrix: Matrix<Int> = [[1, 2], [4, 5], [7, 8]]
        matrix.columns.append([3, 6, 9])
        XCTAssertTrue([[1, 2, 3], [4, 5, 6], [7, 8, 9]] == matrix)
        matrix.rows.append([10, 11, 12])
        XCTAssertTrue([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]] == matrix)
        matrix.columns.removeFirst(2)
        XCTAssertTrue([[3], [6], [9], [12]] == matrix)
        matrix.columns.append(contentsOf: [[0, 0, 0, 0], [1, 2, 3, 4]])
        XCTAssertTrue([[3, 0, 1], [6, 0, 2], [9, 0, 3], [12, 0, 4]] == matrix)
        matrix.columns.removeAll()
        XCTAssertTrue(matrix.rows.count == 0)
        matrix.rows.append([1, 2, 3, 4, 5, 6])
        matrix.columns.append([7])
        XCTAssertTrue(matrix == [[1, 2, 3, 4, 5, 6, 7]])
        matrix.rows.removeAll()
        matrix.columns.append(contentsOf: [[1, 2, 3], [4, 5, 6]])
        XCTAssertTrue(matrix == [[1, 4], [2, 5], [3, 6]])
        matrix.rows.insert([11, 12], at: 2)
        matrix.columns.insert([0, -1, -2, -3], at: 1)
        XCTAssertTrue(matrix == [[1, 0, 4], [2, -1, 5], [11, -2, 12], [3, -3, 6]])
    }
    
    func testMapping() {
        let matrix: Matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        XCTAssertTrue([[true, false, true], [false, true, false], [true, false, true]] == matrix.map { $0 % 2 == 1 })
        XCTAssertTrue([[1, 4, 9], [16, 25, 36], [49, 64, 81]] == matrix.map { $0 * $0 })
    }
    
    func testTranspose() {
        let matrix: Matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        XCTAssertTrue([[1, 4, 7], [2, 5, 8], [3, 6, 9]] == matrix.transpose)
    }
    
    func testRepeatedValue() {
        XCTAssertTrue([[1, 1, 1], [1, 1, 1]] == Matrix(repeating: 1, dimensions: (3, 2)))
        XCTAssertTrue([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]] == Matrix.identity(size: 4))
    }
    
    func testArithmetic() {
        let a: Matrix = [[1, 2], [3, 4], [5, 6]]
        XCTAssertTrue(-a == a - (2 * a))
        XCTAssertTrue(a - 1 == [[0, 1], [2,3], [4,5]])
        XCTAssertTrue(1 - a == [[0, -1], [-2,-3], [-4,-5]])
        XCTAssertTrue(1 + a == [[2, 3], [4,5], [6,7]])
        XCTAssertTrue(a + 1 == [[2, 3], [4,5], [6,7]])
    }
    
    func testDot() {
        let a: Matrix = [[1, 2], [3, 4], [5, 6]]
        let b: Matrix = [[2, 2], [4, 3], [1, 7]]
        XCTAssertTrue(77 == a.dot(b))
    }
    
    func testDeterminant() {
        XCTAssertTrue(3 == Matrix([[1, 3], [1, 6]]).determinant)
        XCTAssertTrue(-4627 == Matrix([[2, 3, 3, 6], [2, 3, 6, 7], [21, 82, 0 ,3], [2, 23, 1, 1]]).determinant)
    }
    
    func testCofactor() {
        XCTAssertTrue([[24, 5, -4], [-12, 3, 2], [-2, -5, 4]] == Matrix([[1, 2, 3], [0, 4, 5], [1, 0, 6]]).cofactor)
        XCTAssertTrue([[24, -12, -2], [5, 3, -5], [-4, 2, 4]] == Matrix([[1, 2, 3], [0, 4, 5], [1, 0, 6]]).adjoint)
        XCTAssertTrue((1.0 / 22) * [[24, -12, -2], [5, 3, -5], [-4, 2, 4]] == Matrix([[1, 2, 3], [0, 4, 5], [1, 0, 6]]).inverse)
    }
    
    func testMatrixMultiplication() {
        XCTAssertTrue([[0, -5], [-6, -7]] == [[1, 0, -2], [0, 3, -1]] * [[0, 3], [-2, -1], [0, 4]])
    }
    
    func testRowViewColumnViewInitialization() {
        let a: Matrix = Matrix([[1, 2], [3, 4]] as RowView)
        let b: Matrix = Matrix([[1, 3], [2, 4]] as ColumnView)
        XCTAssertTrue(a == b)
    }

}
