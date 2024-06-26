# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))

# require first for stdlib_test
require "find"
require "fileutils"

require "minitest/mock"
require "minitest/autorun"
require "minitest/focus"

$VERBOSE = true

require "live_ast/base"

class JLMiniTest < Minitest::Test
  def self.test_methods
    default = super
    onlies = default.grep(/__only\Z/)
    if onlies.empty?
      default
    else
      puts "\nNOTE: running ONLY *__only tests for #{self}"
      onlies
    end
  end

  def unfixable
    yield
    raise "claimed to be unfixable, but assertion succeeded"
  rescue Minitest::Assertion
  end

  def assert_nothing_raised
    yield
  rescue StandardError => e
    raise Minitest::Assertion,
          exception_details(e, "Expected nothing raised, but got:")
  end

  %w(
    empty equal in_delta in_epsilon includes instance_of
    kind_of match nil operator respond_to same
  ).each { |name|
    alias_method :"assert_not_#{name}", :"refute_#{name}"
  }
end

class BaseTest < JLMiniTest
  include LiveAST.parser::Test

  DATA_DIR = File.expand_path("data", File.dirname(__FILE__))

  def self.stdlib_has_source?
    RUBY_ENGINE != "jruby"
  end

  def temp_file(code, basename = nil)
    basename ||= "#{("a".."z").to_a.shuffle.join}.rb"
    path = File.join(DATA_DIR, basename)

    write_file path, code if code
    begin
      yield path
    ensure
      FileUtils.rm_f path
    end
  end

  def write_file(file, contents)
    File.open(file, "w") { |f| f.print contents }
  end

  def return_block(&block)
    block
  end

  def exception_backtrace
    yield
  rescue Exception => e
    e.backtrace
  end

  def ignore(*_args); end
end

class RegularTest < BaseTest
  def setup
    super
    require "live_ast"
  end
end

class ReplaceEvalTest < BaseTest
  def initialize(*args)
    super
    ok = begin
           require "live_ast/full"
           true
         rescue LoadError
           raise "need: gem install bindings" if RUBY_ENGINE == "ruby"

           false
         end

    return if ok

    self.class.class_eval do
      instance_methods(false).each do |m|
        remove_method(m)
        define_method(m) { nil }
      end
    end
  end
end
