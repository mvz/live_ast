# frozen_string_literal: true

module LiveAST
  module Common
    module_function

    def arg_to_str(arg)
      arg.to_str
    rescue NameError
      thing = arg.nil? ? nil : arg.class

      message = "no implicit conversion of #{thing.inspect} into String"
      raise TypeError, message
    end

    def arg_to_str2(arg)
      arg.to_str
    rescue NameError
      thing = arg.nil? ? nil : arg.class

      message = "wrong argument type #{thing.inspect} (expected String)"
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

    def location_for_eval(*args)
      bind, *location = args

      if bind
        case location.size
        when 0
          bind.source_location
        when 1
          [location.first, 1]
        else
          location
        end
      else
        ["(eval)", 1]
      end
    end
  end
end
