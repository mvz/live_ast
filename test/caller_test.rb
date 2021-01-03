# frozen_string_literal: true

require_relative "main"

# test for optional caller redefinition: unsort this TestCase from
# other TestCases.

define_unsorted_test_case "CallerTest", RegularTest do
  def test_replace_caller
    raise_after_eval("caller", false)

    require "live_ast/replace_caller"

    raise_after_eval("caller", true)
  end

  def raise_after_eval(code, will_succeed)
    orig = eval %{
        foo = nil
        1.times do
          foo = caller
        end
        foo
    }, binding, "somewhere", 1000

    live = ast_eval %{
        foo = nil
        1.times do
          foo = caller
        end
        foo
    }, binding, "somewhere", 1000

    orig_top = orig.first
    live_top = live.first

    assert_equal orig_top, LiveAST.strip_token(live_top)

    if will_succeed
      assert_equal orig_top, live_top
      assert_match(/somewhere:1002/, live_top)
    else
      assert_not_equal orig_top, live_top
      assert_match(/somewhere.*?:1002/, live_top)
    end
  end
end
