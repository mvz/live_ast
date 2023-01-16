# frozen_string_literal: true

require "test_helper"

class ASTReloadTest < ReplaceEvalTest
  include FileUtils

  def test_reloading
    ast_reload
  end

  def ast_reload
    code1 = <<~RUBY
      class ASTReloadTest::C
        def f
          "first C#f"
        end
      end
    RUBY

    code2 = <<~RUBY
      class ASTReloadTest::C
        def f
          "second C#f"
        end
      end
    RUBY

    temp_file code1 do |file|
      load file

      LiveAST.ast(C.instance_method(:f))

      write_file file, code2
      load file

      assert_equal no_arg_def(:f, "second C#f"),
                   LiveAST.ast(C.instance_method(:f))
    end
  end
end
