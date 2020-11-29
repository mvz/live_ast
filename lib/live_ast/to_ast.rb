# frozen_string_literal: true

require "live_ast/base"

class Method
  # Extract the AST of this object.
  def to_ast #:nodoc:
    LiveAST::Linker.find_method_ast(owner, name, *source_location)
  end
end

class UnboundMethod
  # Extract the AST of this object.
  def to_ast #:nodoc:
    LiveAST::Linker.find_method_ast(owner, name, *source_location)
  end
end

class Proc
  # Extract the AST of this object.
  def to_ast
    LiveAST::Linker.find_proc_ast(self)
  end
end
