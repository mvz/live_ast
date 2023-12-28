# frozen_string_literal: true

require "live_ast/base"

module Kernel
  private

  alias live_ast_original_caller caller

  def caller(...)
    c = live_ast_original_caller(...)
    c.shift
    c.map { |line| LiveAST.strip_token line }
  end
end
