# frozen_string_literal: true

require_relative "main"

class StdlibTest < RegularTest
  if stdlib_has_source?
    def test_pp
      pp_method = method(:pp)
      assert_equal "<internal:prelude>", pp_method.source_location.first
      assert_raises LiveAST::ASTNotFoundError do
        pp_method.to_ast
      end
    end

    def test_find
      assert_not_nil Find.method(:find).to_ast
    end
  end
end
