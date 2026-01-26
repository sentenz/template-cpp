---
name: api-documentation
description: Automates API documentation creation for C++ projects using Doxygen with consistent documentation patterns and Google C++ Style Guide conventions. Use when creating, modifying, or reviewing API documentation, adding doc comments to code, or when the user mentions Doxygen, API docs, or code documentation.
metadata:
  author: sentenz
  version: "1.0"
---

# API Documentation

Instructions for AI coding agents on automating API documentation creation using Doxygen with consistent documentation patterns in this C++ project.

- [1. Benefits](#1-benefits)
- [2. Principles](#2-principles)
  - [2.1. Documentation Hierarchy](#21-documentation-hierarchy)
- [3. Patterns](#3-patterns)
  - [3.1. File Documentation](#31-file-documentation)
  - [3.2. Class Documentation](#32-class-documentation)
  - [3.3. Function Documentation](#33-function-documentation)
  - [3.4. Member Documentation](#34-member-documentation)
  - [3.5. Grouping and Modules](#35-grouping-and-modules)
- [4. Workflow](#4-workflow)
- [5. Commands](#5-commands)
- [6. Style Guide](#6-style-guide)
- [7. Template](#7-template)
  - [7.1. File Header Template](#71-file-header-template)
  - [7.2. Class Template](#72-class-template)
  - [7.3. Function Template](#73-function-template)
  - [7.4. Member Variable Template](#74-member-variable-template)
  - [7.5. Enum Template](#75-enum-template)
  - [7.6. Module/Group Template](#76-modulegroup-template)
- [8. References](#8-references)

## 1. Benefits

- Discoverability
  > Well-documented APIs enable developers to quickly understand and use components without reading implementation details.

- Maintainability
  > Consistent documentation reduces onboarding time and helps maintainers understand design decisions and constraints.

- Automation
  > Doxygen generates navigable HTML, LaTeX, and XML documentation from source code comments, integrating with CI/CD pipelines.

- Traceability
  > Documentation comments serve as living specifications, keeping API contracts synchronized with implementation.

## 2. Principles

### 2.1. Documentation Hierarchy

The documentation hierarchy ensures comprehensive coverage at all levels.

- File Level
  > Every header file should have a file-level comment describing its purpose, author, and license.

- Class Level
  > Each class or struct should have a brief description explaining its responsibility and usage context.

- Function Level
  > Public functions require documentation of parameters, return values, exceptions, and preconditions/postconditions.

- Member Level
  > Non-trivial member variables should have inline comments explaining their purpose.

## 3. Patterns

### 3.1. File Documentation

File-level documentation provides context for the entire file.

- Purpose
  > Describes the file's role in the project architecture.

- Author
  > Identifies the original author(s) of the file.

- License
  > Specifies the licensing terms (typically SPDX identifier).

### 3.2. Class Documentation

Class-level documentation describes the abstraction.

- Brief
  > A one-line summary of what the class represents.

- Details
  > Extended description of responsibilities, invariants, and usage patterns.

- Template Parameters
  > For template classes, document each template parameter's purpose and constraints.

### 3.3. Function Documentation

Function-level documentation describes the contract.

- Brief
  > A one-line summary of what the function does.

- Parameters
  > Document each parameter with `@param` including direction (`[in]`, `[out]`, `[in,out]`).

- Return Value
  > Document the return value with `@return` or `@retval` for specific values.

- Exceptions
  > Document thrown exceptions with `@throws` or `@exception`.

- Preconditions
  > Document preconditions with `@pre`.

- Postconditions
  > Document postconditions with `@post`.

### 3.4. Member Documentation

Member-level documentation clarifies data semantics.

- Inline Comments
  > Use `///< description` for trailing inline documentation.

- Block Comments
  > Use `/// description` for preceding documentation.

### 3.5. Grouping and Modules

Organize related elements into logical groups.

- Defgroups
  > Use `@defgroup` to create named documentation modules.

- Ingroups
  > Use `@ingroup` to add elements to existing groups.

- Memberof
  > Use `@memberof` for explicit class membership.

## 4. Workflow

1. Identify

    Identify undocumented or poorly documented public APIs in `src/` (e.g., `src/<module>/<header>.hpp`).

2. Add/Create

    Add Doxygen-compatible documentation comments to header files following the templates below.

3. Validate Documentation

    Generate documentation locally to verify formatting and completeness.

4. Documentation Coverage Requirements

    Include comprehensive documentation for:

    - All public classes, structs, and enums
    - All public and protected member functions
    - All function parameters and return values
    - All template parameters
    - Exception specifications
    - Thread safety guarantees when applicable
    - Complexity guarantees for algorithms

5. Apply Templates

    Structure all documentation using the template patterns below.

## 5. Commands

| Command               | Description                                        |
| --------------------- | -------------------------------------------------- |
| `doxygen Doxyfile`    | Generate documentation from Doxyfile configuration |
| `doxygen -g Doxyfile` | Generate a default Doxyfile configuration template |
| `doxygen -u Doxyfile` | Update an existing Doxyfile to the latest format   |

## 6. Style Guide

- Documentation Framework
  > Use [Doxygen](https://www.doxygen.nl/) via `/** */` block comments or `///` line comments.

- Comment Style
  > Prefer `///` for single-line documentation and `/** */` for multi-line documentation blocks. Use Javadoc-style commands (`@param`, `@return`) rather than Qt-style (`\param`, `\return`).

- Language
  > Write documentation in clear, concise English. Use present tense for descriptions ("Returns the sum" not "Will return the sum").

- Placement
  > Place documentation comments immediately before the documented element in header files. Implementation files (`.cpp`) should not duplicate header documentation.

- Brief Descriptions
  > Use `@brief` for explicit brief descriptions, or rely on the first sentence as the brief when `JAVADOC_AUTOBRIEF` is enabled.

- Parameter Direction
  > Always specify parameter direction:
  - `@param[in]` for input parameters
  - `@param[out]` for output parameters
  - `@param[in,out]` for bidirectional parameters

- Consistency
  > Follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html#Comments) conventions for comments.

- Code Examples
  > Use `@code` and `@endcode` blocks for usage examples within documentation.

- Cross-References
  > Use `@see` to reference related functions, classes, or external resources.

- Deprecation
  > Mark deprecated APIs with `@deprecated` including migration guidance.

- TODO Items
  > Use `@todo` for planned improvements visible in generated documentation.

## 7. Template

Use these templates for new documentation. Replace placeholders with actual values and adjust as needed for the use case.

### 7.1. File Header Template

```cpp
/**
 * @file <filename>.hpp
 * @brief Brief description of the file's purpose.
 *
 * Detailed description of the file's contents, design decisions,
 * and any important notes for developers.
 *
 * @author <author_name>
 * @copyright Copyright (c) <year> <organization>
 * @license SPDX-License-Identifier: Apache-2.0
 */

#pragma once
```

### 7.2. Class Template

```cpp
/**
 * @brief Brief one-line description of the class.
 *
 * Detailed description of the class including:
 * - Its responsibility and role in the system
 * - Key invariants maintained by the class
 * - Thread safety guarantees
 * - Example usage patterns
 *
 * @code
 * MyClass obj;
 * obj.doSomething();
 * @endcode
 *
 * @tparam T Description of template parameter T.
 *
 * @see RelatedClass
 * @since 1.0
 */
template <typename T>
class MyClass
{
  // ...
};
```

### 7.3. Function Template

```cpp
/**
 * @brief Brief one-line description of what the function does.
 *
 * Detailed description of the function including algorithm details,
 * edge cases, and usage notes.
 *
 * @param[in] param1 Description of the first input parameter.
 * @param[out] param2 Description of the output parameter.
 * @param[in,out] param3 Description of bidirectional parameter.
 *
 * @return Description of the return value.
 * @retval specific_value Meaning of this specific return value.
 *
 * @throws std::invalid_argument If param1 is invalid.
 * @throws std::runtime_error If operation fails.
 *
 * @pre Preconditions that must be met before calling.
 * @post Postconditions guaranteed after successful return.
 *
 * @note Any important notes for users.
 * @warning Any warnings about potential misuse.
 *
 * @complexity O(n) where n is the size of param1.
 *
 * @code
 * auto result = myFunction(input, output);
 * @endcode
 *
 * @see relatedFunction
 */
ReturnType myFunction(const InputType& param1, OutputType& param2);
```

### 7.4. Member Variable Template

```cpp
class MyClass
{
private:
  int count_;       ///< Number of items currently stored.
  bool is_valid_;   ///< Whether the object is in a valid state.

  /**
   * @brief Buffer for temporary storage.
   *
   * Detailed explanation of the member's purpose, lifetime,
   * and any synchronization requirements.
   */
  std::vector<char> buffer_;
};
```

### 7.5. Enum Template

```cpp
/**
 * @brief Brief description of what this enumeration represents.
 *
 * Detailed description of the enum's purpose and usage context.
 */
enum class Status
{
  kSuccess,     ///< Operation completed successfully.
  kError,       ///< Operation failed with an error.
  kPending,     ///< Operation is still in progress.
  kNotFound     ///< Requested item was not found.
};
```

### 7.6. Module/Group Template

```cpp
/**
 * @defgroup module_name Module Display Name
 * @brief Brief description of the module.
 *
 * Detailed description of the module's purpose, components,
 * and how they work together.
 *
 * @{
 */

// Classes and functions belonging to this group

/** @} */ // end of module_name
```

## 8. References

- Doxygen [Manual](https://www.doxygen.nl/manual/) guide.
- Doxygen [Commands](https://www.doxygen.nl/manual/commands.html) reference.
- Doxygen [Configuration](https://www.doxygen.nl/manual/config.html) reference.
- Google C++ Style Guide [Comments](https://google.github.io/styleguide/cppguide.html#Comments) section.
