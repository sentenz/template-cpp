# AGENTS.md

- [1. Software Testing](#1-software-testing)
  - [1.1. Unit Testing](#11-unit-testing)
    - [1.1.1. Testing Patterns](#111-testing-patterns)
    - [1.1.2. Test Workflow](#112-test-workflow)
    - [1.1.3. Test Commands](#113-test-commands)
    - [1.1.4. Test Style](#114-test-style)
    - [1.1.5. Test Template](#115-test-template)
  - [1.2. Fuzz Testing](#12-fuzz-testing)
  - [1.3. Benchmark Testing](#13-benchmark-testing)

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

#### 1.1.1. Testing Patterns

- In-Got-Want
  > In-Got-Want is a software testing pattern that structures test cases into three distinct sections of In (input), Got (actual output), and Want (expected output).

- Table-Driven Testing
  > Table-Driven Testing is a software testing technique in which test cases are organized in a tabular format.

- Data-Driven Testing (DDT)
  > Data-Driven Testing (DDT) is a software testing methodology that separates test data from test logic, allowing the same test logic to be executed with multiple sets of input data (e.g., JSON, CSV).

- Arrange, Act, Assert (AAA)
  > Arrange, Act, Assert (AAA) is a software testing pattern that structures test cases into three distinct phases of Arrange (setup), Act (execution), and Assert (verification).

- Test Fixtures
  > Test Fixtures are a software testing pattern that provides a consistent and reusable setup and teardown mechanism for test cases.

#### 1.1.2. Test Workflow

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

    Structure all tests using this [template](#15-test-template) pattern.

#### 1.1.3. Test Commands

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

#### 1.1.4. Test Style

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

#### 1.1.5. Test Template

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

### 1.2. Fuzz Testing

Instructions for AI coding agents on automating fuzz test creation using consistent software testing patterns in this C++ project.

<!-- TODO -->

### 1.3. Benchmark Testing

Instructions for AI coding agents on automating benchmark test creation using consistent software testing patterns in this C++ project.

<!-- TODO -->
