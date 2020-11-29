# frozen_string_literal: true

require "live_ast/base"

module LiveAST
  module MethodToAST
    # Extract the AST of this object.
    def to_ast
      LiveAST::Linker.find_method_ast(owner, name, *source_location)
    end
  end

  module ProcToAST
    # Extract the AST of this object.
    def to_ast
      LiveAST::Linker.find_proc_ast(self)
    end
  end
end

Method.include LiveAST::MethodToAST
UnboundMethod.include LiveAST::MethodToAST
Proc.include LiveAST::ProcToAST
