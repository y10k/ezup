#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'ezup'
require 'test/unit'

module EasyUp::Test
  class BuilderTest < Test::Unit::TestCase
    def setup
      @b = EasyUp::Builder.new
    end

    class SimpleMiddleware
      def initialize(app)
	@app = app
      end

      attr_reader :app
    end

    class Foo < SimpleMiddleware; end
    class Bar < SimpleMiddleware; end
    class Baz < SimpleMiddleware; end

    def test_builder
      @b.use Foo
      @b.use Bar
      @b.use Baz

      app = proc{|env|
	[ 200, { 'Content-Type' => 'text/plain' },
	  [ "Hello world." ]
	]
      }
      wrapped_app = @b.wrap_app(app)

      assert_instance_of(Foo, wrapped_app)
      assert_instance_of(Bar, wrapped_app.app)
      assert_instance_of(Baz, wrapped_app.app.app)
      assert_equal(app, wrapped_app.app.app.app)
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
