# -*- coding: utf-8 -*-
# CGI environment easy setup and easy upload.

require 'forwardable'

module EasyUp
  module LocalRunner
    class Config
      def initialize(cgi_app, cgi_name)
        @cgi_app = cgi_app
        @cgi_name = cgi_name
        @server = Rack::Handler::WEBrick
        @options = { :Port => 8080 }
      end

      attr_reader :cgi_app
      attr_reader :cgi_name
      attr_accessor :server
      attr_reader :options
    end

    class DSL
      extend Forwardable

      def initialize(config, builder)
        @c = config
        @b = builder
      end

      def_delegator :@c, :cgi_app
      def_delegator :@c, :cgi_name

      def server(server)
        @c.server = server
        nil
      end

      def port(port)
        @c.options[:Port] = port
        nil
      end

      def host(host)
        @c.options[:Host] = host
        nil
      end

      def option(name, value)
        @c.option[name] = value
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
          if (config.server.respond_to? :shutdown) then
            config.server.shutdown
          else
            exit
          end
        }
      end

      config.server.run(builder.to_app, config.options)
    end
  end
end

include EasyUp::LocalRunner

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
