# frozen_string_literal: true

require_relative "test_helper"
require_relative "../devel/levitate"

class RubygemsTest < RegularTest
  def test_rubygems
    lib = File.expand_path("../lib", File.dirname(__FILE__))
    extra_req =
      if defined?(LiveASTRipper) && LiveAST.parser == LiveASTRipper
        %{require 'live_ast_ripper'}
      else
        ""
      end
    result = Levitate.run_code_and_capture %{
      $LOAD_PATH.unshift '#{lib}'
      #{extra_req}
      require 'live_ast/full'
      LiveAST.parser::Test
      f = eval %{
        lambda { 'abc' }
      }
      p f.to_ast
    }

    assert_equal no_arg_block(:lambda, "abc").to_s, result.chomp
  end
end
