# frozen_string_literal: true

require "live_ast/base"

module LiveAST
  module CallableToRuby
    # Generate ruby code which reflects the AST of this object.
    def to_ruby
      LiveAST.parser::Unparser.unparse(LiveAST.ast(self))
    end
  end
end

Method.include LiveAST::CallableToRuby
UnboundMethod.include LiveAST::CallableToRuby
Proc.include LiveAST::CallableToRuby
