#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'ezup'
require 'ezup/compiler'
require 'test/unit'

module EasyUp::Test
  class CompilerTest < Test::Unit::TestCase
    LIB_DIR = File.join(File.dirname(__FILE__), 'lib_compiler_test')

    def setup
      $: << LIB_DIR unless ($:.include? LIB_DIR)
      @c = EasyUp::Compiler.new
      @c.add_include_path(LIB_DIR)
    end

    def test_scan_include_libraries
      require 'foo'
      @c.scan_include_libraries
      assert_equal(%w[ ezup/builder foo bar foo/baz ].sort,
                   @c.include_libraries.map{|i| i.name }.sort)
    end

    def test_parse
      src = <<-'EOF'.each_line.to_a
#!/usr/bin/ruby
# -*- coding: utf-8 -*-

print "Hello world.\n"
      EOF

      data = @c.parse(src)
      assert_equal("#!/usr/bin/ruby\n", data.shebang)
      assert_equal([ "# -*- coding: utf-8 -*-\n" ], data.header)
      assert_equal([ "\n", "print \"Hello world.\\n\"\n" ], data.body)
    end

    def test_parse_no_shebang
      src = <<-'EOF'.each_line.to_a
# -*- coding: utf-8 -*-

print "Hello world.\n"
      EOF

      data = @c.parse(src)
      assert_equal(nil, data.shebang)
      assert_equal([ "# -*- coding: utf-8 -*-\n" ], data.header)
      assert_equal([ "\n", "print \"Hello world.\\n\"\n" ], data.body)
    end

    def test_parse_no_header
      src = <<-'EOF'.each_line.to_a
#!/usr/bin/ruby

print "Hello world.\n"
      EOF

      data = @c.parse(src)
      assert_equal("#!/usr/bin/ruby\n", data.shebang)
      assert_equal([], data.header)
      assert_equal([ "\n", "print \"Hello world.\\n\"\n" ], data.body)
    end

    def test_parse_no_body
      src = <<-'EOF'.each_line.to_a
#!/usr/bin/ruby
# -*- coding: utf-8 -*-
      EOF

      data = @c.parse(src)
      assert_equal("#!/usr/bin/ruby\n", data.shebang)
      assert_equal([ "# -*- coding: utf-8 -*-\n" ], data.header)
      assert_equal([], data.body)
    end

    def test_parse_body_only
      src = <<-'EOF'.each_line.to_a
print "Hello world.\n"
      EOF

      data = @c.parse(src)
      assert_equal(nil, data.shebang)
      assert_equal([], data.header)
      assert_equal([ "print \"Hello world.\\n\"\n" ], data.body)
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
