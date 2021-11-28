# frozen_string_literal: true

require_relative "main"

# test for optional caller redefinition: unsort this TestCase from
# other TestCases.

class CallerTest < RegularTest
  def test_replace_caller
    raise_after_eval("caller", false)

    require "live_ast/replace_caller"

    raise_after_eval("caller", true)
  end

  def raise_after_eval(code, will_succeed)
    orig = eval <<~RUBY, binding, "somewhere", 1000
      foo = nil
      1.times do
        foo = caller
      end
      foo
    RUBY

    live = ast_eval <<~RUBY, binding, "somewhere", 1000
      foo = nil
      1.times do
        foo = caller
      end
      foo
    RUBY

    orig_top = orig.first
    live_top = live.first

    assert_equal orig_top, LiveAST.strip_token(live_top)

    if will_succeed
      assert_equal orig_top, live_top
      assert_match(/somewhere:1001/, live_top)
    else
      assert_not_equal orig_top, live_top
      assert_match(/somewhere.*?:1001/, live_top)
    end
  end
end
