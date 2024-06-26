# frozen_string_literal: true

require_relative "../test_helper"

class FullReplaceEvalTest < ReplaceEvalTest
  RESULT = {}

  def setup
    RESULT.clear
  end

  DEFINE_A = lambda do
    class A
      eval <<~RUBY
        def f(x, y)
          x**y
        end
      RUBY
    end
  end

  def test_a_def_method
    DEFINE_A.call

    assert_equal binop_def(:f, :**), A.instance_method(:f).to_ast
  end

  DEFINE_B = lambda do
    eval <<~RUBY
      class B
        def f(x, y)
          x / y
        end
      end
    RUBY
  end

  def test_def_class
    DEFINE_B.call

    assert_equal "FullReplaceEvalTest::B", B.name
    assert_equal binop_def(:f, :/), B.instance_method(:f).to_ast
  end

  def moo
    a = 22
    ignore(a)
    binding
  end

  def test_binding_eval
    assert_equal 22, moo.eval("a")
    assert_equal 22, moo.eval("lambda { a }").call
  end

  DEFINE_P = lambda do
    class P
      eval <<~RUBY
        def f
          @x = 33
          RESULT[:old] = live_ast_original_eval("@x")
          RESULT[:new] = eval("@x")
        end
      RUBY
    end
  end

  def test_const_lookup
    DEFINE_P.call
    P.new.f

    assert_equal 33, RESULT[:old]
    assert_equal 33, RESULT[:new]
  end

  def test_const_lookup_two
    Class.new do
      eval <<~RUBY
        def f
          @x = 44
          RESULT[:old] = live_ast_original_eval("@x")
          RESULT[:new] = eval("@x")
        end
      RUBY
    end.new.f

    assert_equal 44, RESULT[:old]
    assert_equal 44, RESULT[:new]
  end

  DEFINE_QS = lambda do
    class Q
      class R
        eval <<~RUBY
          def f
            RESULT[:qr] = 55
          end
        RUBY
      end
    end

    module S
      class T
        eval <<~RUBY
          def f
            RESULT[:st] = 66
          end
        RUBY
      end
    end
  end

  def test_const_lookup_three
    DEFINE_QS.call
    Q::R.new.f
    S::T.new.f

    assert_equal 55, RESULT[:qr]
    assert_equal 66, RESULT[:st]
  end

  def test_eval_arg_error
    [[], (1..5).to_a].each do |args|
      orig = assert_raises ArgumentError do
        live_ast_original_eval(*args)
      end
      live = assert_raises ArgumentError do
        eval(*args)
      end

      assert_equal orig.message, live.message
    end
  end

  def test_singleton_eval_arg_error
    [[], (1..5).to_a].each do |args|
      orig = assert_raises ArgumentError do
        Kernel.live_ast_original_singleton_eval(*args)
      end
      live = assert_raises ArgumentError do
        Kernel.eval(*args)
      end

      assert_equal orig.message, live.message
    end
  end

  def test_instance_eval_arity_error_no_block
    [[], (1..10).to_a, ("a".."z").to_a].each do |args|
      orig = assert_raises ArgumentError do
        Object.new.live_ast_original_instance_eval(*args)
      end
      live = assert_raises ArgumentError do
        Object.new.instance_eval(*args)
      end

      assert_equal orig.message, live.message
    end
  end

  def test_instance_eval_code_argument_type_error_no_block
    [[nil], [Object.new], [3], [4, 3, 2]].each do |args|
      orig = assert_raises TypeError do
        Object.new.live_ast_original_instance_eval(*args)
      end
      live = assert_raises TypeError do
        Object.new.instance_eval(*args)
      end

      assert_equal orig.message, live.message
      assert_equal orig.class, live.class
    end
  end

  def test_instance_eval_filename_argument_nil_type_error_no_block
    skip "nil is an acceptable filename argument in Ruby 3.3" if RUBY_VERSION >= "3.3.0"

    orig = assert_raises TypeError do
      Object.new.live_ast_original_instance_eval("1", nil)
    end
    live = assert_raises TypeError do
      Object.new.instance_eval("1", nil)
    end

    assert_equal orig.message, live.message
    assert_equal orig.class, live.class
  end

  def test_instance_eval_filename_argument_nil_ruby_3_3_no_block
    unless RUBY_VERSION >= "3.3.0"
      skip "nil is not an acceptable filename argument before Ruby 3.3"
    end

    assert_equal 1, Object.new.live_ast_original_instance_eval("1", nil)
    assert_equal 1, Object.new.instance_eval("1", nil)
  end

  def test_instance_eval_filename_argument_conversion_type_error_no_block
    orig = assert_raises TypeError do
      Object.new.live_ast_original_instance_eval("1", 23)
    end
    live = assert_raises TypeError do
      Object.new.instance_eval("1", 23)
    end

    assert_equal orig.message, live.message
    assert_equal orig.class, live.class
  end

  def test_instance_eval_arity_error_with_block
    orig = assert_raises ArgumentError do
      Object.new.live_ast_original_instance_eval(3, 4, 5) { nil }
    end
    live = assert_raises ArgumentError do
      Object.new.instance_eval(3, 4, 5) { nil }
    end

    assert_equal orig.message, live.message
  end

  def test_instance_eval_block
    orig = {}
    orig.live_ast_original_instance_eval do
      self[:x] = 33
    end

    assert_equal 33, orig[:x]

    live = {}
    live.instance_eval do
      self[:x] = 44
    end

    assert_equal 44, live[:x]
  end

  def test_instance_eval_string
    orig = {}
    orig.live_ast_original_instance_eval <<~RUBY
      self[:x] = 33
    RUBY

    assert_equal 33, orig[:x]

    live = {}
    live.instance_eval <<~RUBY
      self[:x] = 44
    RUBY

    assert_equal 44, live[:x]
  end

  def test_instance_eval_binding
    x = 33
    orig = {}
    orig.live_ast_original_instance_eval <<~RUBY
      self[:x] = x
      self[:f] = lambda { "f" }
    RUBY

    assert_equal x, orig[:x]

    y = 44
    live = {}
    live.instance_eval <<~RUBY
      self[:y] = y
      self[:g] = lambda { "g" }
    RUBY

    assert_equal y, live[:y]

    assert_equal no_arg_block(:lambda, "g"), live[:g].to_ast
  end

  def test_module_eval_block
    orig = Module.new
    # rubocop:disable Lint/NestedMethodDefinition
    orig.live_ast_original_module_eval do
      def f
        "orig"
      end
    end
    # rubocop:enable Lint/NestedMethodDefinition
    refute_nil orig.instance_method(:f)

    live = Module.new
    live.module_eval do
      def f
        "live"
      end
    end

    assert_equal no_arg_def(:f, "live"),
                 live.instance_method(:f).to_ast
  end

  def test_module_eval_string
    orig = Module.new
    orig.live_ast_original_module_eval <<~RUBY
      def f
        "orig"
      end
    RUBY

    refute_nil orig.instance_method(:f)

    live = Module.new
    live.module_eval <<~RUBY
      def h
        "live h"
      end
    RUBY

    assert_equal no_arg_def(:h, "live h"),
                 live.instance_method(:h).to_ast
  end

  def test_module_eval_binding
    x = 33
    ignore(x)
    orig = Class.new
    orig.live_ast_original_module_eval <<~RUBY
      define_method :value do
        x
      end
      define_method :f do
        lambda { }
      end
    RUBY

    assert_equal 33, orig.new.value
    assert_kind_of Proc, orig.new.f

    y = 44
    ignore(y)
    live = Class.new
    live.module_eval <<~RUBY
      define_method :value do
        y
      end
      define_method :g do
        lambda { "g return" }
      end
    RUBY

    assert_equal 44, live.new.value
    assert_kind_of Proc, live.new.g

    assert_equal no_arg_block(:lambda, "g return"),
                 live.new.g.to_ast
  end

  def test_module_eval_file_line
    klass = Module.new

    orig =
      klass.live_ast_original_module_eval("[__FILE__, __LINE__]", "test", 102)
    live =
      klass.module_eval("[__FILE__, __LINE__]", "test", 102)

    unfixable do
      assert_equal orig, live
    end

    live.first.sub!(/#{Regexp.quote LiveAST::Linker::REVISION_TOKEN}.*\Z/, "")

    assert_equal orig, live
    assert_equal ["test", 102], live
  end

  def test_module_eval_to_str
    file = Minitest::Mock.new
    file.expect(:to_str, "zebra.rb")
    file.expect(:nil?, false)
    Class.new.module_eval("33 + 44", file)
    file.verify
  end

  def test_eval_not_hosed
    assert_equal 3, eval("1 + 2")
    assert_equal 3, eval("1 + 2")

    assert_equal(3, eval(%{ eval("1 + 2") }))
    assert_equal(3, eval(%{ eval("1 + 2") }))

    x = 5
    eval <<~RUBY
      assert_equal(3, eval(' eval("1 + 2") '))
      x = 6
    RUBY

    assert_equal 6, x
  end

  def test_local_var_collision
    args = 33
    ignore(args)

    assert_equal 33, live_ast_original_eval("args")
    assert_equal 33, eval("args")

    assert_equal 33, Kernel.live_ast_original_singleton_eval("args")
    assert_equal 33, Kernel.eval("args")

    assert_equal 33, binding.live_ast_original_binding_eval("args")
    assert_equal 33, binding.eval("args")

    assert_equal 33, Object.new.live_ast_original_instance_eval("args")
    assert_equal 33, Object.new.instance_eval("args")

    assert_equal 33, Class.new.live_ast_original_module_eval("args")
    assert_equal 33, Class.new.module_eval("args")

    assert_equal 33, Class.new.live_ast_original_instance_eval("args")
    assert_equal 33, Class.new.instance_eval("args")
  end

  def test_eval_location_without_binding
    expected_file = if RUBY_VERSION >= "3.3.0"
                      /^\(eval at #{__FILE__}:[0-9]+\)$/
                    else
                      /^\(eval\)$/
                    end

    file, line = live_ast_original_eval("\n[__FILE__, __LINE__]")

    assert_match expected_file, file
    assert_equal 2, line

    file, line = eval("\n[__FILE__, __LINE__]")
    adjusted_file = LiveAST.strip_token file

    refute_match expected_file, file
    assert_match expected_file, adjusted_file
    assert_equal 2, line
  end

  def test_eval_location_with_binding
    expected_file = if RUBY_VERSION >= "3.3.0"
                      /^\(eval at #{__FILE__}:[0-9]+\)$/
                    else
                      /^\(eval\)$/
                    end

    file, line = live_ast_original_eval("\n[__FILE__, __LINE__]", binding)

    assert_match expected_file, file
    assert_equal 2, line

    file, line = eval("\n[__FILE__, __LINE__]", binding)
    adjusted_file = LiveAST.strip_token file

    refute_match expected_file, file
    assert_match expected_file, adjusted_file
    assert_equal 2, line
  end

  DEFINE_BO_TEST = lambda do
    class BasicObject
      Kernel.eval("1 + 1")
    end
  end

  def test_basic_object
    ::BasicObject.new.instance_eval <<~RUBY
      t = 33
      ::FullReplaceEvalTest::RESULT[:bo_test] = t + 44
    RUBY

    assert_equal 77, RESULT[:bo_test]
  end

  class Z
    def initialize
      @t = 99
    end
  end

  def test_instance_variables
    assert_equal 99, Z.new.instance_eval { @t }
    assert_equal 99, Z.new.instance_eval("@t")
  end
end
