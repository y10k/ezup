# -*- coding: utf-8 -*-

server Rack::Handler::WEBrick
port 8080

use Rack::ShowExceptions
use Rack::Lint

map '/' do
  run proc{|env|
    r = Rack::Request.new(env)
    redirect_url = "#{r.scheme}://#{r.host_with_port}/#{cgi_name}"
    [ 302, { 'Location' => redirect_url }, '' ]
  }
end

map "/#{cgi_name}" do
  run cgi_app
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
