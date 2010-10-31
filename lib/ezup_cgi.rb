# -*- coding: utf-8 -*-
# CGI environment easy setup and easy upload.

module EasyUp
  module CGIRunner
    HTTP_STATUS_CODES = {
      100  => 'Continue',
      101  => 'Switching Protocols',
      102  => 'Processing',
      200  => 'OK',
      201  => 'Created',
      202  => 'Accepted',
      203  => 'Non-Authoritative Information',
      204  => 'No Content',
      205  => 'Reset Content',
      206  => 'Partial Content',
      207  => 'Multi-Status',
      226  => 'IM Used',
      300  => 'Multiple Choices',
      301  => 'Moved Permanently',
      302  => 'Found',
      303  => 'See Other',
      304  => 'Not Modified',
      305  => 'Use Proxy',
      306  => 'Reserved',
      307  => 'Temporary Redirect',
      400  => 'Bad Request',
      401  => 'Unauthorized',
      402  => 'Payment Required',
      403  => 'Forbidden',
      404  => 'Not Found',
      405  => 'Method Not Allowed',
      406  => 'Not Acceptable',
      407  => 'Proxy Authentication Required',
      408  => 'Request Timeout',
      409  => 'Conflict',
      410  => 'Gone',
      411  => 'Length Required',
      412  => 'Precondition Failed',
      413  => 'Request Entity Too Large',
      414  => 'Request-URI Too Long',
      415  => 'Unsupported Media Type',
      416  => 'Requested Range Not Satisfiable',
      417  => 'Expectation Failed',
      422  => 'Unprocessable Entity',
      423  => 'Locked',
      424  => 'Failed Dependency',
      426  => 'Upgrade Required',
      500  => 'Internal Server Error',
      501  => 'Not Implemented',
      502  => 'Bad Gateway',
      503  => 'Service Unavailable',
      504  => 'Gateway Timeout',
      505  => 'HTTP Version Not Supported',
      506  => 'Variant Also Negotiates',
      507  => 'Insufficient Storage',
      510  => 'Not Extended',
    }

    def ezup_run
      STDIN.binmode
      STDIN.set_encoding(Encoding::ASCII_8BIT)

      STDOUT.binmode
      STDOUT.set_encoding(Encoding::ASCII_8BIT)

      STDERR.binmode
      STDERR.set_encoding(Encoding::US_ASCII)

      env = ENV.to_hash
      env['rack.version'] = [ 1, 1 ]
      env['rack.url_scheme'] = (ENV['HTTPS'] =~ /^yes|^on|^1/i) ? 'https' : 'http'
      env['rack.input'] = STDIN
      env['rack.errors'] = STDERR
      env['rack.multithread'] = false
      env['rack.multiprocess'] = true
      env['rack.run_once'] = true

      status, header, body = ezup_main(env)

      STDOUT.print "Status: #{status} #{HTTP_STATUS_CODES[status] || 'Unknown'}\r\n"
      for name, value in header
        STDOUT.print "#{name}: #{value}\r\n"
      end
      STDOUT.print "\r\n"
      for part in body
        STDOUT.print body
        STDOUT.flush
      end

      nil
    end
    module_function :ezup_run
  end
end

def ezup_run
  EasyUp::CGIRunner.ezup_run
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
