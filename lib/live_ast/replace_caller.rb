# frozen_string_literal: true

require "live_ast/base"

module Kernel
  private

  alias live_ast_original_caller caller
  def caller(*args)
    c = live_ast_original_caller(*args)
    c.shift
    d = []
    c.each { |s| d << s.gsub(/\|ast@.*:(\d)/,':\1') }
    d
  end
end
