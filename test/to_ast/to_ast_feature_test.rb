# frozen_string_literal: true

require "main"

require "live_ast/to_ast"

class ToASTFeatureTest < BaseTest
  def test_require
    [Method, UnboundMethod, Proc].each { |obj|
      assert_includes obj.instance_methods, :to_ast
    }
  end
end
