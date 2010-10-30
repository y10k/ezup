# -*- coding: utf-8 -*-

port 8080
handler Rack::Handler::WEBrick

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
