# frozen_string_literal: true

module LiveAST
  module Evaler
    class << self
      include Common

      def eval(parser_source, evaler_source, bind, filename = nil, lineno = nil)
        evaler_source = arg_to_str evaler_source
        check_is_binding bind
        filename = arg_to_str filename if filename

        file, line = location_for_eval(bind, filename, lineno)
        file = LiveAST.strip_token(file)

        key, = Linker.new_cache_synced(parser_source, file, line, false)

        begin
          NATIVE_EVAL.call(evaler_source, bind, key, line)
        rescue Exception => e
          e.backtrace.map! { |s| LiveAST.strip_token s }
          raise e
        end
      end
    end
  end
end
