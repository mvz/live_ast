# frozen_string_literal: true

require "live_ast/base"

module Kernel
  private

  # The same as +eval+ except that the binding argument is required
  # and AST-accessible objects are created.
  def ast_eval(string, bind, filename = nil, lineno = nil)
    LiveAST::Evaler.eval(string, string, bind, filename, lineno)
  end
end
