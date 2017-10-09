//
//  Vector.swift
//  MaxDiffDesigner
//
//  Created by John Howell on 1/24/17.
//  Copyright © 2017 John Howell. All rights reserved.
//  Modified by Vladislav Lisyanskiy on 9/10/2017. - Converted to Swift 4.
//

import Foundation

extension Array where Element: FloatingPointArithmetic {
    public func dot(_ vector: [Element]) -> Element {
        precondition(self.count == vector.count, "Vectors are not the same length")
        return zip(self, vector).map { $0.0 * $0.1 }.reduce(Element(0), +)
    }
    
    public func outer(_ vector: [Element]) -> Matrix<Element> {
        precondition(self.count == vector.count, "Vectors are not the same length")
        return Matrix([self] as ColumnView) * Matrix([vector] as RowView)
    }
    
    public func norm() -> Element {
        return self.map { $0 * $0 }.reduce(Element(0), +)
    }
    
    public static func -(rhs: [Element], lhs: [Element]) -> [Element] {
        precondition(rhs.count == lhs.count)
        return zip(rhs, lhs).map { $0 - $1 }
    }
    
    public static func -(rhs: Element, lhs: [Element]) -> [Element] {
        return lhs.map { rhs - $0 }
    }
    
    public static func -(rhs: [Element], lhs: Element) -> [Element] {
        return rhs.map { $0 - lhs }
    }
    
    public static func +(rhs: [Element], lhs: [Element]) -> [Element] {
        precondition(rhs.count == lhs.count)
        return zip(rhs, lhs).map { $0 + $1 }
    }
    
    public static func +(rhs: Element, lhs: [Element]) -> [Element] {
        return lhs.map { rhs + $0 }
    }
    
    public static func +(rhs: [Element], lhs: Element) -> [Element] {
        return rhs.map { $0 + lhs }
    }
    
    public static func *(rhs: [Element], lhs: [Element]) -> [Element] {
        precondition(rhs.count == lhs.count)
        return zip(rhs, lhs).map { $0 * $1 }
    }
    
    public static func *(rhs: Element, lhs: [Element]) -> [Element] {
        return lhs.map { rhs * $0 }
    }
    
    public static func *(rhs: [Element], lhs: Element) -> [Element] {
        return rhs.map { $0 * lhs }
    }
    
    public static func /(rhs: [Element], lhs: [Element]) -> [Element] {
        precondition(rhs.count == lhs.count)
        return zip(rhs, lhs).map { $0 / $1 }
    }
    
    public static func /(rhs: Element, lhs: [Element]) -> [Element] {
        return lhs.map { rhs / $0 }
    }
    
    public static func /(rhs: [Element], lhs: Element) -> [Element] {
        return rhs.map { $0 / lhs }
    }
    
    public static prefix func -(value: [Element]) -> [Element] {
        return value.map { -$0 }
    }
    public static func zeros(_ n: Int) -> [Element] {
        return Array<Element>(repeating: 0, count: n)
    }
}
