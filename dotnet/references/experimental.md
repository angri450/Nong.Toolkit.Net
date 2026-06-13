# Experimental Skills

Features under active evaluation. May change or graduate to stable.

## Mock Usage Analysis

Analyze how mocks are used in tests to detect over-mocking and suggest improvements.

### Signal detection
```bash
grep -rn "new Mock<\|\.Setup(\|\.Verify(" **/*Tests.cs
```

### Common issues
- Mocking concrete classes instead of interfaces
- Over-verifying (`.Verify()` on every call)
- Mocking types you own instead of fakes/stubs
- Setup without corresponding Verify or use

## SIMD Vectorization

Optimize loops with SIMD intrinsics and `Vector<T>`.

```csharp
using System.Numerics;
using System.Runtime.Intrinsics;

// Vector<T> — platform-width SIMD automatically
void AddArrays(float[] a, float[] b, float[] result)
{
    int i = 0;
    int vectorSize = Vector<float>.Count;
    for (; i <= a.Length - vectorSize; i += vectorSize)
    {
        var va = new Vector<float>(a, i);
        var vb = new Vector<float>(b, i);
        (va + vb).CopyTo(result, i);
    }
    for (; i < a.Length; i++)
        result[i] = a[i] + b[i];
}
```

### When to apply
- Hot loops with simple arithmetic
- Large arrays (1K+ elements)
- Uniform operations (no branching inside loop)
- Verify with BenchmarkDotNet before/after

## Test Maintainability

Reduce test fragility by focusing on behavior, not implementation.

### Principles
- Test public API, not private methods
- Prefer state-based verification over interaction-based
- One logical assertion per test
- Avoid test ordering dependencies
- Use builders/test data factories for complex objects

### Smell detection
```bash
# Tests referencing private members
grep -rn "PrivateObject\|PrivateType\|GetField\|GetMethod" **/*Tests.cs

# Multiple asserts (candidate for splitting)
grep -c "Assert\." **/*Tests.cs | sort -t: -k2 -rn | head
```

## Validation
- [ ] Experimental features are clearly marked
- [ ] Use is opt-in and reversible
- [ ] Performance changes verified with benchmarks
