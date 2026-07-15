---
name: swift-testing-patterns
description: >-
  Modern testing with Swift Testing framework (not XCTest). Spy pattern for Interactors,
  SUT (Subject Under Test) in init, parameterized tests with @Test(arguments:),
  @Suite organization, and #expect assertions. Use when writing unit tests, creating
  test spies, setting up test suites, or user mentions "Swift Testing", "@Test",
  "#expect", "Spy", "parameterized test", or "unit test".
user-invocable: true
when_to_use: |
  When writing unit tests, creating test spies, or setting up test suites. When the user mentions "Swift Testing", "@Test", "#expect", "Spy", "SUT", "parameterized test", or "unit test".
---

## Overview

Always use Swift Testing (`import Testing`) — never XCTest for unit tests. Create Spy implementations of Interactor protocols in the test target with `wasCalled` tracking properties. Use the SUT pattern (Subject Under Test initialized in `init()`) to keep tests DRY. Use `@Test(arguments:)` with custom argument structs for parameterized tests.

> **Project-specific settings**: Before applying this skill, check `CLAUDE.md` for:
> - Test framework preference (Swift Testing vs. XCTest for unit tests)
> - Test target name and folder structure
> - Spy naming convention (Spy vs. Fake vs. Mock)
> - Spy location convention (`Tests/Shared/Spies/` or similar)
> - App module name for `@testable import`

## Instructions

1. **Create Spy** — in the test target, implement the Interactor protocol with `wasCalled` booleans and `last*` capture properties
2. **Create test suite** — `@Suite("Feature Name") struct FeatureTests {}` in `Tests/Features/[Feature]/`
3. **Add sub-suites** — use `extension FeatureTests { @Suite("ViewModel Tests") ... }` in separate files
4. **Set up SUT** — instantiate Spy and ViewModel in `init()`, store as `let` properties
5. **Write test** — `@Test("Descriptive name") func testName() async {}` with Given/When/Then
6. **Assert** — use `#expect()` for all assertions, `await #expect(throws:)` for error testing
7. **Add arguments** — for multiple scenarios, create argument structs conforming to `CustomTestStringConvertible`

## Rules

### Framework

- **Always** use `import Testing` — never `import XCTest` for unit tests
- **Always** use `@testable import [AppName]` to access `internal` types
- Use `#expect()` for assertions — never `XCTAssert*`
- Use `await #expect(throws: SpecificError.self)` for error testing

### Spy Implementation

- Every Interactor protocol gets a Spy in the test target
- Spy naming: `Spy[Feature]Interactor` (check CLAUDE.md for project convention)
- Every Spy needs: `wasCalled` booleans, `last*` capture properties, stub data properties, and a `reset()` method
- Spy must be `@MainActor` — protects mutable tracking state without bypassing compiler verification. Never use `@unchecked Sendable`.
- Location: `[App]Tests/Shared/Spies/Spy[Feature]Interactor.swift` (or as defined in CLAUDE.md)

### SUT Pattern (Subject Under Test)

- Instantiate Spy and ViewModel/SUT in the test struct's `init()`
- Store as `let` properties on the test struct — no repetition in each test
- Only create SUT inside a test when testing different init parameters via `@Test(arguments:)`

### Test Organization

- Main suite: `@Suite("Feature Name") struct FeatureTests {}`
- Sub-suites in separate files: `FeatureTests+ViewModel.swift`, `FeatureTests+Interactor.swift`
- MARK order inside test structs: `// MARK: - Subject Under Test` → `// MARK: - Spies` → `// MARK: - Initializers` → `// MARK: - Tests`
- Test data and argument types go in `private extension` with their own MARK comments

### Parameterized Tests

- Create argument structs conforming to `CustomTestStringConvertible`
- Provide `var testDescription: String` for readable test names
- Always include explicit `init` (required for `@Test(arguments:)`)
- Cast the arguments array: `as [ArgumentType]`
- Put argument structs in `private extension` under `// MARK: - Arguments`

### ViewModel Tests

- Annotate test struct with `@MainActor` — ViewModels are `@MainActor`
- Test both success and failure paths for every async method
- Verify ViewModel state AND Spy tracking: `#expect(spy.fetchWasCalled == true)`
- Test computed properties by setting up the data they depend on

### Sample Data

- Define `static let` sample data in `private extension` under `// MARK: - Test Data`
- For shared samples across files, create `Model+Samples.swift` in `Tests/Shared/Samples/`
- Use the AAA pattern: **A**rrange (Given), **A**ct (When), **A**ssert (Then)

## Verification Checklist

- [ ] Uses `import Testing` — no XCTest
- [ ] Spy has `wasCalled` booleans and `last*` capture properties
- [ ] Spy has `reset()` method for cleanup
- [ ] Tests use SUT pattern in `init()` for DRY
- [ ] ViewModel tests annotated with `@MainActor`
- [ ] Parameterized tests use `CustomTestStringConvertible` argument structs
- [ ] MARK order: SUT → Spies → Initializers → Tests → Test Data → Arguments
- [ ] AAA pattern: Given → When → Then
- [ ] Test names are descriptive: `@Test("Load items successfully updates array")`
- [ ] Both success AND failure paths tested

## Common Mistakes

- **Using XCTest** → Use Swift Testing (`import Testing`, `@Test`, `#expect`)
- **Calling test Spy "Mock"** → Mock = previews, Spy = tests. Different locations, different purposes. Check CLAUDE.md for your project's convention.
- **No `reset()` method** → Spies accumulate state across tests. Always provide `reset()`.
- **Missing `@MainActor`** → ViewModels are `@MainActor` — test struct must be too.
- **Repeating setup in every test** → Use SUT in `init()` to avoid duplication.
- **No `CustomTestStringConvertible`** → Argument structs need `testDescription` for readable output.

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Full Spy, ViewModel tests with SUT, parameterized tests, suite organization
