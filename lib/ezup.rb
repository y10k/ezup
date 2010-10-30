# -*- coding: utf-8 -*-
# CGI environment easy setup and easy upload.

require 'forwardable'

module EasyUp
  module LocalRunner
    class Config
      def initialize(cgi_app, cgi_name)
        @cgi_app = cgi_app
        @cgi_name = cgi_name
        @port = 8080
        @handler = Rack::Handler::WEBrick
      end

      attr_reader :cgi_app
      attr_reader :cgi_name
      attr_accessor :port
      attr_accessor :handler
    end

    class DSL
      extend Forwardable

      def initialize(config, builder)
        @c = config
        @b = builder
      end

      def_delegator :@c, :cgi_app
      def_delegator :@c, :cgi_name

      def port(port)
        @c.port = port
        nil
      end

      def handler(handler)
        @c.handler = handler
        nil
      end

      def_delegator :@b, :use
      def_delegator :@b, :map
    end

    def ezup_run
      require 'rack'

      cgi_app = proc{|env| ezup_main(env) }
      cgi_name = File.basename($0, '.rb') + '.cgi'

      config = Config.new(cgi_app, cgi_name)
      builder = Rack::Builder.new
      dsl = DSL.new(config, builder)

      conf_path = File.join(File.dirname($0), 'config_local.rb')
      dsl.instance_eval(IO.read(conf_path), conf_path)

      for sig_name in %w[ INT TERM ]
        trap(sig_name) {
          if (config.handler.respond_to? :shutdown) then
            config.handler.shutdown
          else
            exit
          end
        }
      end

      config.handler.run builder.to_app, :Port => config.port
    end
  end
end

include EasyUp::LocalRunner

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
