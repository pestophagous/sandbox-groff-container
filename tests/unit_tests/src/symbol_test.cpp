// #define CATCH_CONFIG_MAIN // done elsewhere - only do this in one cpp file
#include "catch/catch.hpp"

// We have to use a longer path (with 'include/') to the groff headers, or else
// the groff "assert.h" messes without use of catch.hpp
#include "include/symbol.h" // <-- do NOT make our path such that this becomes merely "symbol.h"

#include <memory>
#include <string.h>

TEST_CASE("basic usage", "[symbol_test]")
{
  std::unique_ptr<symbol> sym_null = std::make_unique<symbol>();
  std::unique_ptr<symbol> sym_test = std::make_unique<symbol>("thetest");
  std::unique_ptr<symbol> sym_nostore =
                std::make_unique<symbol>("A", DONT_STORE);

  std::unique_ptr<symbol> sym_want_exist_success =
                std::make_unique<symbol>("thetest", MUST_ALREADY_EXIST);
  std::unique_ptr<symbol> sym_want_exist_fail =
                std::make_unique<symbol>("B", MUST_ALREADY_EXIST);

  REQUIRE(sym_null->is_null() == 1);
  REQUIRE(sym_null->hash() == 0);

  REQUIRE(/*note the ! */ !sym_test->is_null());
  REQUIRE(sym_test->hash() != 0);

  REQUIRE(/*note the ! */ !sym_nostore->is_null());
  REQUIRE(strncmp(sym_nostore->contents(), "A", 1) == 0);

  REQUIRE(/*note the ! */ !sym_want_exist_success->is_null());
  REQUIRE(sym_want_exist_fail->is_null() == 1);
}
