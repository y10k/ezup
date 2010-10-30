# -*- coding: utf-8 -*-
# CGI environment easy setup and easy upload.

module EasyUp
  module LocalRunner
    def ezup_run
      require 'rack'

      cgi_name = File.basename($0, '.rb') + '.cgi'
      app = Rack::Builder.app{
        map '/' do
          run proc{|env|
            r = Rack::Request.new(env)
            redirect_url = "#{r.scheme}://#{r.host_with_port}/#{cgi_name}"
            [ 302, { 'Location' => redirect_url }, '' ]
          }
        end
        map "/#{cgi_name}" do
          run proc{|env| ezup_main(env) }
        end
      }

      for sig_name in %w[ INT TERM ]
        trap(sig_name) { Rack::Handler::WEBrick.shutdown }
      end

      Rack::Handler::WEBrick.run app, :Port => 8080
    end
  end
end

include EasyUp::LocalRunner

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
