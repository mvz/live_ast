# frozen_string_literal: true

require_relative "../test_helper"

require "live_ast/ast_load"

class AstLoadTest < BaseTest
  include FileUtils

  def test_defines_ast_load
    assert_includes private_methods, :ast_load
  end

  def test_reloading
    noninvasive_ast_reload
  end

  def noninvasive_ast_reload
    code1 = <<~RUBY
      class AstLoadTest::B
        def f
          "first B#f"
        end
      end
    RUBY

    code2 = <<~RUBY
      class AstLoadTest::B
        def f
          "second B#f"
        end
      end
    RUBY

    temp_file code1 do |file|
      load file

      LiveAST.ast(B.instance_method(:f))

      write_file file, code2
      ast_load file

      assert_equal no_arg_def(:f, "second B#f"),
                   LiveAST.ast(B.instance_method(:f))
    end
  end
end
