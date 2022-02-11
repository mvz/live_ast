# frozen_string_literal: true

require "main"

require "live_ast/to_ruby"

class ToRubyFeatureTest < BaseTest
  def test_defines_to_ruby
    [Method, UnboundMethod, Proc].each { |obj|
      assert_includes obj.instance_methods, :to_ruby
    }
  end
end
