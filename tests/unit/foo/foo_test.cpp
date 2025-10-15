// foo_test.cpp
#include "foo/foo.hpp"

#include <filesystem>
#include <fstream>
#include <string>
#include <utility>
#include <vector>

#include <gtest/gtest.h>
#include <nlohmann/json.hpp>

TEST(FooTest, Add)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      int a;
      int b;
    } in;

    struct Want
    {
      int value;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"valid positive input", /* in */ {2, 3}, /* want */ {5}},
      {"valid negative input", /* in */ {-1, -2}, /* want */ {-3}},
      {"zero inputs", /* in */ {0, 0}, /* want */ {0}},
      {"mixed sign", /* in */ {5, -3}, /* want */ {2}},
      {"int max + 0", /* in */ {INT_MAX, 0}, /* want */ {INT_MAX}},
      {"int min + 0", /* in */ {INT_MIN, 0}, /* want */ {INT_MIN}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    cpp_concept::Foo foo;

    // Act
    auto got = foo.add(tc.in.a, tc.in.b);

    // Assert
    EXPECT_EQ(got, tc.want.value);
  }
}

class FooFixture : public ::testing::Test
{
protected:
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      std::string text;
    } in;

    struct Want
    {
      std::string text;
    } want;
  };

  // Data-Driven Testing
  std::vector<Tests> tests;

  void SetUp() override
  {
    // Load and parse JSON
    std::string filename = "foo_test.json";
    std::filesystem::path filepath = std::filesystem::path(__FILE__).parent_path() / filename;
    std::ifstream file(filepath);
    ASSERT_TRUE(file.good()) << "Failed to open JSON: " << filepath.string();

    nlohmann::json data = nlohmann::json::parse(file);
    for (const auto &row : data["foo::greet"])
    {
      Tests tmp;
      tmp.label = row.at("label").get<std::string>();
      tmp.in.text = row.at("in").at("text").get<std::string>();
      tmp.want.text = row.at("want").at("text").get<std::string>();

      tests.push_back(std::move(tmp));
    }

    ASSERT_FALSE(tests.empty()) << "Failed to parse JSON: " << filepath.string();
  }

  void TearDown() override
  {
    // Cleanup
    tests.clear();
  }
};

TEST_F(FooFixture, Greet)
{
  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    cpp_concept::Foo foo;

    // Act
    const auto got = foo.greet(tc.in.text);

    // Assert
    EXPECT_EQ(got, tc.want.text);
  }
}
