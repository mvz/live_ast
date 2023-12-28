# frozen_string_literal: true

require_relative "../test_helper"

class NonInvasiveErrorTest < BaseTest
  def test_arg_error_too_many
    orig = assert_raises ArgumentError do
      eval("s", binding, "f", 99, nil)
    end

    live = assert_raises ArgumentError do
      LiveAST.eval("s", binding, "f", 99, nil)
    end

    assert_equal orig.message.sub("1..4", "2..4"), live.message
  end

  def test_bad_args
    [99, Object.new, File].each do |bad|
      orig = assert_raises TypeError do
        eval(bad, binding)
      end
      live = assert_raises TypeError do
        LiveAST.eval(bad, binding)
      end

      assert_equal orig.message, live.message

      orig = assert_raises TypeError do
        eval("3 + 4", binding, bad)
      end
      live = assert_raises TypeError do
        LiveAST.eval("3 + 4", binding, bad)
      end

      assert_equal orig.message, live.message
    end
  end

  def test_bad_binding
    orig = assert_raises TypeError do
      eval("", "bogus")
    end

    live = assert_raises TypeError do
      LiveAST.eval("", "bogus")
    end

    assert_equal orig.message, live.message
  end

  def test_shenanigans
    error = assert_raises RuntimeError do
      LiveAST.load "foo.rb|ast@4"
    end

    assert_match(/revision token/, error.message)
  end
end
