# AGENTS.md

- [1. Software Testing](#1-software-testing)
  - [1.1. Unit Testing](#11-unit-testing)
    - [1.1.1. Unit Testing Patterns](#111-unit-testing-patterns)
    - [1.1.2. Unit Test Workflow](#112-unit-test-workflow)
    - [1.1.3. Unit Test Commands](#113-unit-test-commands)
    - [1.1.4. Unit Test Style](#114-unit-test-style)
    - [1.1.5. Unit Test Template](#115-unit-test-template)
  - [1.2. Mock Testing](#12-mock-testing)
    - [1.2.1. Mock Testing Patterns](#121-mock-testing-patterns)
    - [1.2.2. Mock Test Workflow](#122-mock-test-workflow)
    - [1.2.3. Mock Test Commands](#123-mock-test-commands)
    - [1.2.4. Mock Test Style](#124-mock-test-style)
    - [1.2.5. Mock Test Template](#125-mock-test-template)
  - [1.3. Fuzz Testing](#13-fuzz-testing)
  - [1.4. Benchmark Testing](#14-benchmark-testing)

## 1. Software Testing

### 1.1. Unit Testing

Instructions for AI coding agents on automating unit test creation using consistent software testing patterns in this C++ project.

1. Features and Benefits

    - Readability
      > Ensures high code quality and reliability. Tests are self-documenting, reducing cognitive load for reviewers and maintainers.

    - Consistency
      > Uniform structure across tests ensures predictable, familiar code that team members can navigate efficiently.

    - Scalability
      > Table-driven and data-driven approaches minimize boilerplate code when adding new test cases, making it simple to expand coverage.

    - Debuggability
      > Scoped traces and detailed assertion messages pinpoint failures quickly during continuous integration and local testing.

#### 1.1.1. Unit Testing Patterns

- In-Got-Want
  > In-Got-Want is a software testing pattern that structures test cases into three distinct sections of In (input), Got (actual output), and Want (expected output).

- Table-Driven Testing
  > Table-Driven Testing is a software testing technique in which test cases are organized in a tabular format.

- Data-Driven Testing (DDT)
  > Data-Driven Testing (DDT) is a software testing methodology that separates test data from test logic, allowing the same test logic to be executed with multiple sets of input data (e.g., JSON, CSV).

- Arrange, Act, Assert (AAA)
  > Arrange, Act, Assert (AAA) is a software testing pattern that structures test cases into three distinct phases of Arrange (setup), Act (execution), and Assert (verification).

- Test Fixtures
  > Test Fixtures are a software testing pattern that provides a consistent and reusable `setup` and `teardown` mechanism for test cases.

- Test Doubles
  > Test Doubles (e.g., mocks, stubs, fakes) involves creating simplified versions of complex objects or components to isolate the unit under test.

#### 1.1.2. Unit Test Workflow

1. Identify

    Identify new functions in `src/` (e.g., `src/<module>/<header>.hpp`).

2. Add/Create

    Create new tests under `tests/unit/<module>/` (e.g., `tests/unit/<module>/<header>_test.cpp`).

3. Test Coverage Requirements

    Include comprehensive edge cases:
    - Coverage-guided cases
    - Boundary values (min/max limits, edge thresholds)
    - Empty/null inputs
    - Null pointers and invalid references
    - Overflow/underflow scenarios
    - Special cases (negative numbers, zero, special states)

4. Apply Templates

    Structure all tests using this [template](#115-unit-test-template) pattern.

#### 1.1.3. Unit Test Commands

- Build Unit Tests
  > CMake preset configuration and Compile with Ninja.

  ```bash
  make cmake-gcc-test-unit-build
  ```

- Run Unit Tests
  > Execute tests via ctest.

  ```bash
  make cmake-gcc-test-unit-run
  ```

- Run Code Coverage
  > Generate coverage reports.

  ```bash
  make cmake-gcc-test-unit-coverage
  ```

#### 1.1.4. Unit Test Style

- Test Framework
  > Use [GoogleTest (GTest)](https://google.github.io/googletest/) framework via `#include <gtest/gtest.h>`.

- Include Headers
  > Include necessary standard library headers (`<vector>`, `<string>`, `<climits>`, etc.) and module-specific headers in a logical order: system headers first, then project headers.

- Namespace
  > Use `using namespace <namespace>;` for convenience within test functions to reduce verbosity while maintaining clarity, since test scope is limited.

- Test Organization
  > Consolidate test cases for a single function into **one `TEST(...)` function** using table-driven testing. This approach:
  > - Eliminates redundant test function definitions
  > - Simplifies maintenance by grouping related scenarios together
  > - Reduces code duplication in setup and teardown phases
  > - Makes it easier to add or modify test cases

- Testing Macros
  > Focus each `TEST(...)` function on a single function or cohesive behavior. For complex setups, use `TEST_F` fixtures or helper functions to reduce duplication.

- Traceability
  > Employ [`SCOPED_TRACE(tc.label)`](https://google.github.io/googletest/reference/testing.html#SCOPED_TRACE) for traceable failures in table-driven tests.

- Assertions
  > Use `EXPECT_*` macros (not `ASSERT_*`) to allow all test cases to run.

#### 1.1.5. Unit Test Template

Use this template (In-Got-Want + Table-Driven + AAA) for new test functions. Replace placeholders with actual values and adjust as needed for the use case.

```cpp
#include <gtest/gtest.h>

#include <vector>
#include <string>

#include "<module>/<header>.hpp"

using namespace <namespace>;

TEST(<Module>Test, <FunctionName>)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      /* input types and names */
    } in;

    struct Want
    {
      /* expected output type(s) and name(s) */
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
    {"case description 1", /* in */ {/* input values */}, /* want */ {/* expected output */}},
    {"case description 2", /* in */ {/* input values */}, /* want */ {/* expected output */}},
    // add more cases as needed
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    <Module> <object>;
    // additional setup as needed

    // Act
    auto got = <object>.<function>(tc.in.<input>);

    // Assert
    EXPECT_EQ(got, tc.want.<expected>);
  }
}
```

### 1.2. Mock Testing

Instructions for AI coding agents on automating mock test creation using Google Mock (GMock) with consistent software testing patterns in this C++ project.

1. Features and Benefits

    - Isolation
      > Isolates the unit under test from external dependencies, ensuring tests focus on the specific component's behavior.

    - Control
      > Provides precise control over dependency behavior through expectations and return values, enabling thorough testing of edge cases and error conditions.

    - Verification
      > Automatically verifies that dependencies are called correctly with expected parameters and call counts.

    - Flexibility
      > Supports various testing scenarios including strict mocks, nice mocks, and sequence verification for complex interactions.

#### 1.2.1. Mock Testing Patterns

- Mock Objects
  > Mock Objects are simulated objects that mimic the behavior of real objects in controlled ways. They verify interactions between the unit under test and its dependencies.

- Interface Mocking
  > Interface Mocking involves creating mock implementations of abstract interfaces or base classes to isolate the unit under test from concrete implementations.

- Behavior Verification
  > Behavior Verification focuses on verifying that methods are called with expected arguments and in the correct order, rather than just checking return values.

- Return Value Stubbing
  > Return Value Stubbing configures mock objects to return specific values when their methods are called, allowing control over dependency behavior during tests.

- Exception Injection
  > Exception Injection uses mocks to simulate error conditions by throwing exceptions, enabling tests to verify error handling logic.

#### 1.2.2. Mock Test Workflow

1. Identify Dependencies

    Identify interfaces or classes that need to be mocked (e.g., database connections, file systems, network services, external APIs).

2. Create Mock Classes

    Create mock classes for interfaces under `tests/unit/<module>/` using GMock's `MOCK_METHOD` macro.

3. Define Expectations

    Set up expectations using `EXPECT_CALL` to specify:
    - Which methods should be called
    - Expected arguments (using matchers)
    - Call frequency (Times, AtLeast, AtMost, etc.)
    - Return values or actions

4. Test Coverage Requirements

    Include comprehensive scenarios:
    - Normal operation with mocked dependencies
    - Error conditions (exceptions, null returns, invalid data)
    - Boundary conditions in dependency interactions
    - Sequence of calls to multiple dependencies
    - Concurrent access scenarios when applicable

5. Apply Templates

    Structure all tests using this [template](#125-mock-test-template) pattern.

#### 1.2.3. Mock Test Commands

- Build Mock Tests
  > CMake preset configuration with GMock support and Compile with Ninja.

  ```bash
  make cmake-gcc-test-unit-build
  ```

- Run Mock Tests
  > Execute tests via ctest (mock tests are part of unit tests).

  ```bash
  make cmake-gcc-test-unit-run
  ```

- Run Code Coverage
  > Generate coverage reports including mock test coverage.

  ```bash
  make cmake-gcc-test-unit-coverage
  ```

#### 1.2.4. Mock Test Style

- Test Framework
  > Use [Google Mock (GMock)](https://google.github.io/googletest/gmock_for_dummies.html) framework via `#include <gmock/gmock.h>` and `#include <gtest/gtest.h>`.

- Mock Class Definition
  > Define mock classes inheriting from the interface to be mocked. Use `MOCK_METHOD` macro with proper method signature, including const qualifiers and override specifiers.

- Include Headers
  > Include necessary headers in this order:
  > 1. GMock/GTest headers (`<gmock/gmock.h>`, `<gtest/gtest.h>`)
  > 2. Standard library headers (`<memory>`, `<string>`, etc.)
  > 3. Project interface headers
  > 4. Project implementation headers
  >
  > Note: GMock/GTest headers are listed first as they are the testing framework headers and should be included before other headers to avoid potential conflicts.

- Namespace
  > Use `using namespace <namespace>;` and `using namespace ::testing;` for convenience within test functions to access GMock matchers and actions.

- Test Organization
  > Use table-driven testing for multiple scenarios with the same mock setup. Each `TEST` or `TEST_F` should focus on one aspect of the interaction with mocked dependencies.

- Mock Types
  > - **NiceMock**: Ignores unexpected calls (use for non-critical dependencies)
  > - **StrictMock**: Fails on any unexpected calls (use for strict verification)
  > - **Default Mock**: Warns on unexpected calls (balanced approach)

- Expectations
  > - Use `EXPECT_CALL` to set up expectations before exercising the unit under test
  > - Chain matchers with `.With()`, `.WillOnce()`, `.WillRepeatedly()`, `.Times()`
  > - Prefer specific matchers (`Eq()`, `Gt()`, `_`) over generic ones when possible

- Matchers and Actions
  > - Use built-in matchers: `_` (anything), `Eq()`, `Ne()`, `Lt()`, `Gt()`, `Le()`, `Ge()`, `IsNull()`, `NotNull()`
  > - Container matchers: `IsEmpty()`, `SizeIs()`, `Contains()`, `ElementsAre()`
  > - String matchers: `StartsWith()`, `EndsWith()`, `HasSubstr()`, `MatchesRegex()`
  > - Use `Return()`, `ReturnRef()`, `Throw()`, `DoAll()`, `Invoke()` for actions

- Sequence Verification
  > Use `InSequence` or `Sequence` objects when call order matters.

- Traceability
  > Employ `SCOPED_TRACE(tc.label)` for traceable failures in table-driven mock tests.

- Assertions
  > Use `EXPECT_*` macros to allow all test cases to run. Mock expectations are automatically verified at the end of each test.

- Documentation References
  > - [GMock for Dummies](https://google.github.io/googletest/gmock_for_dummies.html) - Getting started guide
  > - [GMock Cookbook](https://google.github.io/googletest/gmock_cook_book.html) - Advanced techniques and recipes
  > - [GMock Cheat Sheet](https://google.github.io/googletest/gmock_cheat_sheet.html) - Quick reference for matchers and actions

#### 1.2.5. Mock Test Template

Use this template (In-Got-Want + Table-Driven + AAA + Mocks) for new mock test functions. Replace placeholders with actual values and adjust as needed for the use case.

```cpp
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <memory>
#include <string>
#include <vector>

#include "<module>/<interface>.hpp"
#include "<module>/<implementation>.hpp"

using namespace <namespace>;
using namespace ::testing;

// Mock class definition
class Mock<Interface> : public <Interface>
{
public:
  MOCK_METHOD(<return_type>, <method_name>, (<param_types>), (override));
  MOCK_METHOD(<return_type>, <method_name2>, (<param_types>), (const, override));
  // Add more MOCK_METHOD declarations as needed
};

TEST(<Module>Test, <FunctionName>WithMock)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      /* input types and names */
    } in;

    struct Want
    {
      /* expected output type(s) and name(s) */
      /* expected mock call parameters and behavior */
      int call_count;         // number of times method should be called
      <return_type> return_value;  // value mock should return
      <param_type> param;     // expected parameter value(s)
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
    {"case description 1", 
     /* in */ {/* input values */}, 
     /* want */ {/* expected output */, /* call_count */ 1, /* return_value */ {}, /* param */ {}}},
    {"case description 2", 
     /* in */ {/* input values */}, 
     /* want */ {/* expected output */, /* call_count */ 1, /* return_value */ {}, /* param */ {}}},
    // add more cases as needed
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    auto mock_dependency = std::make_shared<Mock<Interface>>();
    
    // Set up expectations
    EXPECT_CALL(*mock_dependency, <method_name>(tc.want.param))
        .Times(tc.want.call_count)
        .WillOnce(Return(tc.want.return_value));
    
    <Implementation> object(mock_dependency);
    // additional setup as needed

    // Act
    auto got = object.<function>(tc.in.<input>);

    // Assert
    EXPECT_EQ(got, tc.want.<expected>);
    // Mock expectations are automatically verified here
  }
}

// Example with strict mock and sequence verification
TEST(<Module>Test, <FunctionName>WithSequence)
{
  // Arrange
  auto mock_dependency = std::make_shared<StrictMock<Mock<Interface>>>();
  
  InSequence seq;
  EXPECT_CALL(*mock_dependency, <method1>(_)).WillOnce(Return(<value1>));
  EXPECT_CALL(*mock_dependency, <method2>(_)).WillOnce(Return(<value2>));
  
  <Implementation> object(mock_dependency);

  // Act
  auto got = object.<function>();

  // Assert
  EXPECT_EQ(got, <expected>);
}

// Example with exception testing
TEST(<Module>Test, <FunctionName>WithException)
{
  // Arrange
  auto mock_dependency = std::make_shared<Mock<Interface>>();
  
  EXPECT_CALL(*mock_dependency, <method_name>(_))
      .WillOnce(Throw(std::runtime_error("test error")));
  
  <Implementation> object(mock_dependency);

  // Act & Assert
  EXPECT_THROW(object.<function>(), std::runtime_error);
}
```

### 1.3. Fuzz Testing

Instructions for AI coding agents on automating fuzz test creation using consistent software testing patterns in this C++ project.

<!-- TODO -->

### 1.4. Benchmark Testing

Instructions for AI coding agents on automating benchmark test creation using consistent software testing patterns in this C++ project.

<!-- TODO -->
