require 'ruby2ruby'

#
# Used by +to_ruby+ in LiveAST.
#
module LiveAST
  class RubyParser
    module Unparser
      #
      # Return a ruby source string which reflects the given AST.
      #
      def self.unparse(sexp)
        ::Ruby2Ruby.new.process(sexp)
      end
    end
  end
end
