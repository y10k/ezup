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
      assert_equal(%w[ ezup/builder foo ].sort,
                   @c.include_libraries.map{|i| i.name }.sort)
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
