# frozen_string_literal: true

require 'live_ast/base'

module Kernel
  private

  alias live_ast_original_raise raise

  def raise(*args)
    ex = begin
           live_ast_original_raise(*args)
         rescue Exception => e
           e
         end
    ex.backtrace.reject! { |line| line.index __FILE__ }
    ex.backtrace.map! { |line| LiveAST.strip_token line }
    live_ast_original_raise ex
  end
end
