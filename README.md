# Dimensional

Dimensional defines a generic type `Matrix` that is parameterized by the type of element it hold.
```swift
let myBoolMatrix: Matrix = [[true, false], [false, true]]
let myStringMatrix: Matrix = [["hello", "hi", "howdy"], ["goodbye", "bye", "see ya"]]
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

Not only does `Matrix` conform to `MutableCollectionType`, but it exposes two views `RowView` and `ColumnView` each of which conform to `RangeReplaceableCollectionType` allowing for complex manipulations.
```swift
var x: Matrix = [[1, 2], [3, 4]]
x.rows.append([5, 6])
x.columns.insert([3, 6, 9], atIndex: 2)
print(x) // -> [[1, 2, 3], [3, 4, 6], [5, 6, 9]]
```

A `Matrix` can be initialized in many different ways.
```swift
let a: Matrix = Matrix([[1, 2], [3, 4]] as RowView)
let b: Matrix = Matrix([[1, 3], [2, 4]] as ColumnView)
print(a == b) // -> true

let c = Matrix(dimensions: (width: 3, height: 2), repeatedValue: 7)
print(c) // -> [[7, 7, 7], [7, 7, 7]]

let d = Matrix.identity(size: 3)
print(d) // [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
```
