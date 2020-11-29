# frozen_string_literal: true

require "main"

if LiveAST.parser::Test.respond_to?(:unparser_matches_ruby2ruby?) &&
    LiveAST.parser::Test.unparser_matches_ruby2ruby?
  class ToRubyTest < RegularTest
    def setup
      super
      require "live_ast/to_ruby"
    end

    def test_lambda_one
      src = %{lambda { "moo" }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_lambda_two
      src = %{lambda { |x| (x ** 2) }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_lambda_three
      src = %{lambda { |x, y| (x + y) }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_proc_one
      src = %{proc { "moo" }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_proc_two
      src = %{proc { |x| (x ** 2) }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_proc_three
      src = %{proc { |x, y| (x * y) }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_block_one
      src = %{return_block { "moo" }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_block_two
      src = %{return_block { |x| (x ** 2) }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_block_three
      src = %{return_block { |x, y| (x - y) }}
      dst = ast_eval(src, binding).to_ruby
      assert_equal src, dst
    end

    def test_method_one
      src = %{def f\n  "moo"\nend}
      dst = Class.new do
        ast_eval(src, binding)
      end.instance_method(:f).to_ruby
      assert_equal src, dst
    end

    def test_method_two
      src = %{def f(x)\n  (x ** 2)\nend}
      dst = Class.new do
        ast_eval(src, binding)
      end.instance_method(:f).to_ruby
      assert_equal src, dst
    end

    def test_method_three
      src = %{def f(x, y)\n  (x / y)\nend}
      dst = Class.new do
        ast_eval(src, binding)
      end.instance_method(:f).to_ruby
      assert_equal src, dst
    end

    def test_to_ast_after_to_ruby
      src = %{lambda { "moo" }}
      expected_ast = ast_eval(src, binding).to_ast

      lmb = ast_eval(src, binding)
      lmb.to_ruby

      assert_equal expected_ast, lmb.to_ast
    end
  end
end
