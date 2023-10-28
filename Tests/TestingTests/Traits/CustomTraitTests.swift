//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

// Note: Do NOT include `@_spi` on this import. The contents of this file are
// specifically intended to validate that a type conforming to `TestTrait` can
// be declared without importing anything except the base.
import Testing

// This is a "build-only" test which simply validates that we can successfully
// declare a type conforming to `TestTrait` and use its default implementations.
struct MyCustomTrait: TestTrait {}

// This shared state is used to track a counter that starts at 0, gets set to 1
// in `before(for:)` and to 2 in `after(for:)`.
private actor SharedState {
  private var _counter: Int = 0

  fileprivate var counter: Int {
    _counter
  }

  fileprivate func setCounter(_ newValue: Int) {
    _counter = newValue
  }
}

private let sharedState = SharedState()

private struct CustomCountTrait: CustomExecutionTrait & TestTrait {

  func execute(_ function: () async throws -> Void, for test: Test) async throws {
    await sharedState.setCounter(1)
    try await function()
    await sharedState.setCounter(2)
  }
}

struct CustomTraitTest {
  @Test("Execute code before and after a test.", CustomCountTrait())
  func executeCodeBeforeAndAfterATest() async throws {
    await #expect(sharedState.counter == 1)
  }

  @Test("Verify that counter is 2 after first test ran.")
  func verifyCounter() async throws {
    await #expect(sharedState.counter == 2)
  }
}
