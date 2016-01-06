# Dimensional

Dimensional defines a generic type `Matrix` that is parameterized by the type of element it holds.
```swift
let myBoolMatrix: Matrix = [[true, false], [false, true]]
let myStringMatrix: Matrix = [["hello", "hi", "howdy"], ["goodbye", "bye", "see ya"]]

print(myBoolMatrix.map{ $0 ? 1 : 0 }) // -> [[1, 0], [0, 1]]
print(myStringMatrix.transpose) // -> [["hello", "goodbye"], ["hi", "bye"], ["howdy", "see ya"]]
```
Note that matrices can be initialized from 2-dimensional array literals, and that each inner-array represents a row in the constructed `Matrix`.

While a `Matrix` can be parameterized by any type, it is most useful if it is parameterized by some numeric type since it gains tons of special abilities!
```swift
let a: Matrix = [[1, 2], [3, 4]]
let b: Matrix = [[5, 10], [-5, 0]]

print(a.determinant)      // -> -2
print(a.dot(b) * (a + b)) // -> [[60, 120], [-20, 40]]
print(a * b)              // -> [[-5, 10], [-5, 30]]
```
Matrices composed of floating point types gain even more amazing powers, such as the ability to take an inverse!

Not only does `Matrix` conform to `MutableCollectionType`, but it exposes two views `RowView` and `ColumnView` each of which conform to `RangeReplaceableCollectionType` allowing for complex manipulations.
```swift
var x: Matrix = [[1, 2], [3, 4]]
x.rows.append([5, 6])
x.columns.insert([3, 6, 9], atIndex: 2)
print(x) // -> [[1, 2, 3], [3, 4, 6], [5, 6, 9]]
```
I want to reiterate how cool this is! The properties `rows` and `columns` provide collections that not only allow you to inspect a `Matrix`, but also allow you to modify it in really familiar ways. Its interface is nearly identical to that of `Array` since both conform to the same protocols.

A `Matrix` can be initialized in many different novel ways.
```swift
let a: Matrix = Matrix([[1, 2], [3, 4]] as RowView)
let b: Matrix = Matrix([[1, 3], [2, 4]] as ColumnView)
print(a == b) // -> true

let c = Matrix(dimensions: (width: 3, height: 2), repeatedValue: 7)
print(c) // -> [[7, 7, 7], [7, 7, 7]]

let d = Matrix.identity(size: 3)
print(d) // [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
```
