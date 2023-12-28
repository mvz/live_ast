# frozen_string_literal: true

module LiveAST
  module Common
    module_function

    def arg_to_str(arg)
      arg.to_str
    rescue NameError
      thing = arg&.class

      message = "no implicit conversion of #{thing.inspect} into String"
      raise TypeError, message
    end

    def arg_to_str2(arg)
      return "" if arg.nil? && RUBY_VERSION >= "3.3.0"

      arg.to_str
    rescue NameError
      thing = arg&.class

      message = if arg.nil?
                  "wrong argument type #{thing.inspect} (expected String)"
                else
                  "no implicit conversion of #{thing.inspect} into String"
                end

      raise TypeError, message
    end

    def check_arity(args, range)
      return if range.include? args.size

      range = 0 if range == (0..0)

      message = "wrong number of arguments (given #{args.size}, expected #{range})"
      raise ArgumentError, message
    end

    def check_is_binding(obj)
      return if obj.is_a? Binding

      message = "wrong argument type #{obj.class} (expected binding)"
      raise TypeError, message
    end

    def location_for_eval(bind, filename = nil, lineno = nil)
      if filename
        lineno ||= 1
        [filename, lineno]
      elsif RUBY_VERSION >= "3.3.0"
        file, line = bind.source_location
        ["(eval at #{file}:#{line})", 1]
      else
        ["(eval)", 1]
      end
    end
  end
end
