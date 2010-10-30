#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'ezup'

def ezup_main(env)
  [ 200, { 'Content-Type' => 'text/html' },
    [ "<html><body><p>Hello world.</p></body></html>" ]
  ]
end

ezup_run if $0 == __FILE__

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
