require_relative 'main'
require_relative '../devel/levitate'

if LiveAST.parser::Test.respond_to?(:unified_sexp?) and
    LiveAST.parser::Test.unified_sexp?
  sections = [
    "Synopsis",
    "Loading Source",
    "Noninvasive Interface",
    "+to_ruby+",
  ]

  Levitate.doc_to_test("README.rdoc", *sections)
end
