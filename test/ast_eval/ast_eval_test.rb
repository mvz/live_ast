# frozen_string_literal: true

require "test_helper"

require "live_ast/ast_eval"

class ASTEvalTest < BaseTest
  def test_defines_ast_eval
    assert_respond_to self, :ast_eval

    assert_includes private_methods, :ast_eval
  end
end
