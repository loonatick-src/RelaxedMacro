# Relaxed

A Swift macro that transforms arithmetic expressions to use relaxed floating-point operations from [swift-numerics](https://github.com/apple/swift-numerics).

## Overview

The `#relaxed` macro rewrites binary arithmetic operators to use `Relaxed.sum` and `Relaxed.product`, enabling more aggressive compiler optimizations. Relaxed operations allow the compiler to reorder and reassociate floating-point operations, which can improve performance but may produce slightly different results due to floating-point semantics.

## Installation

**TODO:** Cut a release tag. This will not work at the moment.

Add Relaxed to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/loonatick-src/RelaxedMacros.git", from: "1.0.0")
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["Relaxed"]
)
```

## Usage

Import the module and wrap arithmetic expressions with the `#relaxed` macro:

```swift
import Relaxed

let a: Double = 1.0
let b: Double = 2.0
let c: Double = 3.0

let x1 = #relaxed(a + b * c)
// Expands to: Relaxed.sum(a, Relaxed.product(b, c))
let x2 = #relaxed(a * b / c)
// Expands to: Relaxed.product(a, b / c)
let x3 = #relaxed(sin(a + b * c))
// Expands to: sin(Relaxed.sum(a, Relaxed.product(b, c)))
```

## Supported Operators

| Operator | Transformation |
|----------|----------------|
| `+` | `Relaxed.sum(a, b)` |
| `-` | `Relaxed.sum(a, -b)` |
| `*` | `Relaxed.product(a, b)` |
| others | Preserved as-is |

## Examples

### Basic Operations

```swift
// Addition
#relaxed(a + b)
// Expands to: Relaxed.sum(a, b)

// Subtraction
#relaxed(a - b)
// Expands to: Relaxed.sum(a, -b)

// Multiplication
#relaxed(a * b)
// Expands to: Relaxed.product(a, b)

// Division (not transformed)
#relaxed(a / b)
// Expands to: a / b
```

### Nested Expressions

```swift
// Mixed operations
#relaxed(a + b * c)
// Expands to: Relaxed.sum(a, Relaxed.product(b, c))

// Parenthesized expressions
#relaxed((a + b) * (c + d))
// Expands to: Relaxed.product(Relaxed.sum(a, b), Relaxed.sum(c, d))

// Complex expressions
#relaxed(a * b + c * d)
// Expands to: Relaxed.sum(Relaxed.product(a, b), Relaxed.product(c, d))
```

### Function Calls

Arithmetic expressions inside function calls are also transformed:

```swift
#relaxed(sin(a + b * c))
// Expands to: sin(Relaxed.sum(a, Relaxed.product(b, c)))

#relaxed(f(a + b, c * d))
// Expands to: f(Relaxed.sum(a, b), Relaxed.product(c, d))
```


## Why Use Relaxed Operations?

Standard IEEE 754 floating-point arithmetic requires strict ordering of operations, which can prevent certain compiler optimizations. Relaxed operations tell the compiler it's okay to:

- Reorder additions and multiplications
- Reassociate nested operations
- Use fused multiply-add (FMA) instructions

This can lead to significant performance improvements in numerical code, especially in tight loops and vector operations.

Consider the following example.

```
import Relaxed

public func f1(_ a: Float, _ b: Float, _ c: Float) -> Float {
    #relaxed(a * b + c)
}

public func f2(_ a: Float, _ b: Float, _ c: Float) -> Float {
    a * b + c
}
```

This is the generated code on an ARMv8-A machine when the `fmadd` is available.
```
<_$s14RelaxedExample2f2yS2f_S2ftF>:
fmul    s0, s0, s1
fadd    s0, s0, s2
ret

<_$s14RelaxedExample2f1yS2f_S2ftF>:
fmadd   s0, s0, s1, s2
ret
```

## License

3-Clause BSD License
