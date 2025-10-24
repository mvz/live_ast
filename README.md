# LiveAST

## Summary

Live abstract syntax trees of methods and procs. Fork of `live_ast`
(http://quix.github.com/live_ast).

## Synopsis

```ruby
require 'live_ast'

class Greet
  def default
    "hello"
  end
end

#### ASTs of methods

p Greet.instance_method(:default).to_ast
# => s(:defn, :default, s(:args), s(:str, "hello"))

#### ASTs of lambdas, procs, blocks

f = lambda { "foo" }
p f.to_ast
# => s(:iter, s(:call, nil, :lambda), 0, s(:str, "foo"))

def query(&block)
  p block.to_ast
  # => s(:iter, s(:call, nil, :query), 0, s(:str, "bar"))
end

query do
  "bar"
end

#### ASTs from dynamic code -- pure ruby version

u = ast_eval "lambda { 'dynamic3' }", binding
p u.to_ast
# => s(:iter, s(:call, nil, :lambda), 0, s(:str, "dynamic3"))

ast_eval "def v ; 'dynamic4' ; end", binding
p method(:v).to_ast
# => s(:defn, :v, s(:args), s(:str, "dynamic4"))

#### ASTs from dynamic code -- fully integrated version

require 'live_ast/full'

f = eval "lambda { 'dynamic1' }"
p f.to_ast
# => s(:iter, s(:call, nil, :lambda), 0, s(:str, "dynamic1"))

eval "def g ; 'dynamic2' ; end"
p method(:g).to_ast
# => s(:defn, :g, s(:args), s(:str, "dynamic2"))
```

## Install

```shell
% gem install mvz-live_ast
```

## Description

LiveAST enables a program to find the ASTs of objects created by
dynamically generated code. It may be used in a strictly noninvasive
manner, where no standard classes or methods are modified, or it may
be transparently integrated into Ruby. The default setting is in
between.

RubyParser is the default parsing engine. To replace it with Ripper,
`gem install live_ast_ripper` and then `require 'live_ast_ripper'`.
A simple plug-in interface allows LiveAST to
work with any parser.

The advantage of RubyParser is that it gives the traditional ParseTree
sexps used by tools such as `ruby2ruby`.

LiveAST is thread-safe.

Ruby 2.7.0 or higher is required.

## Links

* Home: https://github.com/mvz/live_ast
* Feature Requests, Bug Reports: https://github.com/mvz/live_ast/issues

## `to_ruby`

When the default parser is active,

```ruby
require 'live_ast/to_ruby'
```

will define the `to_ruby` method for the `Method`, `UnboundMethod`,
and `Proc` classes. These methods are one-liners which pass the
extracted ASTs to `ruby2ruby`.

```ruby
require 'live_ast/to_ruby'

p lambda { |x, y| x + y }.to_ruby # => "lambda { |x, y| (x + y) }"

class A
  def f
    "A#f"
  end
end

p A.instance_method(:f).to_ruby # => "def f\n  \"A#f\"\nend"
```

In general, `to_ruby` will hook into the unparser provided by the
parser plug-in, if one is found.

## Pure Ruby and `ast_eval`

An essential feature of `require 'live_ast'` is that it is
implemented in pure ruby. However since pure ruby is not powerful
enough to replace `eval`, in this case `ast_eval` must be used instead
of `eval` for AST-accessible objects. `ast_eval` has the same
semantics as `eval` except that the binding argument is required.

```ruby
require 'live_ast'

u = ast_eval "lambda { 'dynamic3' }", binding
p u.to_ast
# => s(:iter, s(:call, nil, :lambda), 0, s(:str, "dynamic3"))
```

## Full Integration

In order for LiveAST to be transparent to the user, `eval` must be
replaced. This is accomplished with the help of the `bindings` gem
(https://github.com/shreeve/bindings).

To replace `eval`,

```ruby
require 'live_ast/full'
```

The new AST-electrified `eval`, `instance_eval`, `module_eval`,
`class_eval`, and `Binding#eval` all pass RubySpec
(http://rubyspec.org) with the minor exception of backtraces sometimes
not matching that of the original `eval` (see the "Backtraces" section
below for details).

```ruby
require 'live_ast/full'

f = eval "lambda { 'dynamic1' }"
p f.to_ast
# => s(:iter, s(:call, nil, :lambda), 0, s(:str, "dynamic1"))
```

Since LiveAST itself is pure ruby, any platforms supported by `bindings`
should work with `live_ast/full`.

## Limitations

A method or block definition must not share a line with other methods
or blocks in order for its AST to be accessible.

```ruby
require 'live_ast'

class A
  def f ; end ; def g ; end
end
A.instance_method(:f).to_ast # => raises LiveAST::MultipleDefinitionsOnSameLineError

a = lambda { } ; b = lambda { }
a.to_ast # => raises LiveAST::MultipleDefinitionsOnSameLineError
```

Code given to the `-e` command-line switch is not AST-accessible.

Evaled code appearing before `require 'live_ast/full'` is
not AST-accessible.

In some circumstances `ast_eval` and the replaced `eval` will not give
the same backtrace as the original `eval` (next section).

---

## *Technical Issues*

You can probably skip these next sections. Goodbye.

---

## Backtraces

`ast_eval` is meant to be compatible with `eval`. For instance the
first line of `ast_eval`'s backtrace should be identical to that of
`eval`:

```ruby
require 'live_ast'

ast_eval %{ raise "boom" }, binding
# => test.rb:3:in `<main>': boom (RuntimeError)
```

Let's make a slight change,

```ruby
require 'live_ast'

f = ast_eval %{ lambda { raise "boom" } }, binding
f.call
# => test.rb|ast@a:3:in `block in <main>': boom (RuntimeError)
```

What the heck is '`|ast@a`' doing there? LiveAST's
implementation has just been exposed: each source input is assigned a
unique key which enables a Ruby object to find its own definition.

In the first case above, `ast_eval` has removed the key from the
exception backtrace. But in the second case there is no opportunity to
remove it since `ast_eval` has already returned.

If you find this to be problem---for example if you cannot add a
filter for the jump-to-location feature in your editor---then `raise`
may be redefined to strip these tokens,

```ruby
require 'live_ast'
require 'live_ast/replace_raise'

f = ast_eval %{ lambda { raise "boom" } }, binding
f.call
# => test.rb:4:in `block in <main>': boom (RuntimeError)
```

However this only applies to a `raise` call originating from Ruby
code. An exception from within a native method will likely still
contain the token in its backtrace (e.g., in MRI the exception raised
by `1/0` comes from C).

Similarly to replace_raise, there is a replace_caller for libraries that
use the output of Kernel.caller directly to identify files.  This has the
same caveats as replace_raise.

```ruby
require 'live_ast'

f = ast_eval %{ lambda { caller.first } }, binding
f.call
=> "(irb)|ast@o:7:in `irb_binding'"

require 'live_ast/replace_caller'
f.call
=> "(irb):7:in `block in irb_binding'"
```

## Replacing the Parser

Despite its name, LiveAST knows nothing about ASTs. It merely reports
what it finds in the line-to-AST hash returned by the parser's `parse`
method. Replacing the parser class is therefore easy: the only
specification is that the `parse` instance method return such a hash.

To override the default parser with your own,

```ruby
LiveAST.parser = YourParser
```

To test it, provide some examples of what the ASTs look like in
`YourParser::Test`. See `live_ast/ruby_parser` for
reference.

## Noninvasive Mode

For safety purposes, `require 'live_ast'` performs the
invasive act of redefining `load` (but not `require`); otherwise bad
things can happen to the unwary. The addition of `to_ast` to a few
standard Ruby classes is also a meddlesome move.

To avoid these modifications,

```ruby
require 'live_ast/base'
```

will provide the essentials of LiveAST but will not touch core classes
or methods.

To select features individually,

```ruby
require 'live_ast/to_ast'       # define to_ast for Method, UnboundMethod, Proc
require 'live_ast/to_ruby'      # define to_ruby for Method, UnboundMethod, Proc
require 'live_ast/ast_eval'     # define Kernel#ast_eval
require 'live_ast/ast_load'     # define Kernel#ast_load (mentioned below)
require 'live_ast/replace_load' # redefine Kernel#load
```

## Noninvasive Interface

The following alternative interface is available.

```ruby
require 'live_ast/base'

class A
  def f
    "A#f"
  end
end

p LiveAST.ast(A.instance_method(:f))
# => s(:defn, :f, s(:args), s(:str, "A#f"))

p LiveAST.ast(lambda { })
# => s(:iter, s(:call, nil, :lambda), 0)

f = LiveAST.eval("lambda { }", binding)

p LiveAST.ast(f) 
# => s(:iter, s(:call, nil, :lambda), 0)

ast_eval  # => raises NameError
```

## Reloading Files In Noninvasive Mode

Use `ast_load` or (equivalently) `LiveAST.load` when
reloading an AST-aware file.

```ruby
require 'live_ast/ast_load'
require 'live_ast/to_ast'

require "foo"
Foo.instance_method(:bar).to_ast  # caches AST

# ... the bar method is changed in foo.rb ...

ast_load "foo.rb"
p Foo.instance_method(:bar).to_ast  # => updated AST
```

Note if `load` is called instead of `ast_load` then the last line will
give the old AST,

```ruby
load "foo.rb"                       # oops! forgot to use ast_load
p Foo.instance_method(:bar).to_ast  # => stale AST
```

Realize that `foo.rb` may be referenced by an unknown
number of methods and blocks. If the original `foo.rb`
source were dumped in favor of the modified `foo.rb`, then
an unknown number of those references would be invalidated (and some
may even point to the wrong AST).

This is the reason for the caching that results in the stale AST
above. It should now be clear why the default behavior of
`require 'live_ast'` is to redefine `load`: doing so
prevents this problem entirely. On the other hand if it is fully known
where files are being reloaded (if at all) then there's no need for
paranoia; the noninvasive option may be the most appropriate.

## The Source/AST Cache

`ast_eval` and `load` cache all incoming code, while
`require`d files are cached on a need-to-know basis. When
an AST is requested, the corresponding source file is parsed and
discarded, leaving behind method and block ASTs. `to_ast` fetches an
AST from the cache and attaches it to the appropriate object (a Proc
or Module).

Ignored, unextracted ASTs will therefore linger in the cache. Since
sexps are generally small there is little need for concern unless one
is continually evaling/reloading. Nevertheless it is possible that old
ASTs will eventually need to be garbage collected. To flush the cache,

(1) Check that `to_ast` has been called on all objects whose ASTs are 
desired.

(2) Call `LiveAST.flush_cache`.

Calling `to_ast` prevents the object's AST from being flushed (since
it grafts the AST onto the object).

ASTs of procs and methods whose sources lie in `require`d
files will never be flushed. However a method redefined via `ast_eval`
or `load` is susceptible to `flush_cache` even when its original
definition pointed to a `require`d file.

## About `require`

No measures have been taken to detect manipulations of
`$LOADED_FEATURES` which would cause `require` to load the
same file twice. Though `require` *could* be replaced in
similar fashion to `load`---heading off problems arising from such
"raw" reloads---the overhead would seem inappropriate in relation to
the rarity of this case.

Therefore the working assumption is that `require` will load a file
only once. Furthermore, if a file has not been reloaded then it is
assumed that the file is unmodified between the moment it is
`require`d and the moment the first AST is pulled from it.

## Authors

* James M. Lawrence < quixoticsycophant@gmail.com >
* Matijs van Zuijlen < matijs@matijs.net >

## License

```
Copyright (c) 2011 James M. Lawrence. All rights reserved.
Copyright (c) 2014-2022 Matijs van Zuijlen. All rights reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

LiveAST includes the source code of live_ast_ruby_parser, which is licensed as
follows:

```
Copyright (c) 2011 James M. Lawrence. All rights reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
