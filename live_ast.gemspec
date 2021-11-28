# frozen_string_literal: true

require_relative "lib/live_ast/version"

Gem::Specification.new do |spec|
  spec.name = "mvz-live_ast"
  spec.version = LiveAST::VERSION
  spec.authors = ["James M. Lawrence", "Matijs van Zuijlen"]
  spec.email = ["matijs@matijs.net"]

  spec.summary = "Live abstract syntax trees of methods and procs."
  spec.description = <<-DESC
    LiveAST enables a program to find the ASTs of objects created by dynamically
    generated code.
  DESC
  spec.homepage = "https://github.com/mvz/live_ast"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mvz/live_ast"
  spec.metadata["changelog_uri"] = "https://github.com/mvz/live_ast/blob/master/CHANGES.rdoc"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{devel,lib,test}/**/*.rb",
                   "*.rdoc",
                   "Rakefile"]

  spec.rdoc_options = ["--main", "README.rdoc",
                       "--title", "LiveAST: Live Abstract Syntax Trees",
                       "--visibility", "private"]
  spec.extra_rdoc_files = ["README.rdoc", "CHANGES.rdoc"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ruby2ruby", "~> 2.4.0"
  spec.add_runtime_dependency "ruby_parser", "~> 3.14"

  spec.add_development_dependency "bindings", "~> 1.0.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rdoc", "~> 6.2"
  spec.add_development_dependency "rubocop", "~> 1.23.0"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.12.0"
end
