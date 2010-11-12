# -*- coding: utf-8 -*-
# CGI compiler

require 'erb'

module Kernel
  alias ezup_original_autoload autoload

  def autoload(const_name, feature)
    require(feature)
    nil
  end
end

class Module
  alias ezup_original_autoload autoload

  def autoload(const_name, feature)
    require(feature)
    nil
  end
end

module EasyUp
  class Compiler
    EZUP_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + File::SEPARATOR

    def initialize
      @ruby = nil
      @include_path = []
      @include_libraries = []
    end

    attr_accessor :ruby
    attr_reader :include_libraries

    def add_include_path(lib_dir)
      @include_path << File.expand_path(lib_dir)
      self
    end

    LibraryPair = Struct.new(:name, :path)

    def scan_include_libraries
      for lib_dir in @include_path
        unless ($:.include? lib_dir) then
          raise "not a ruby load path: #{lib_dir}"
        end
      end

      for filename in $"
        next if (filename.end_with? '.so')
        if (filename.start_with? EZUP_LIB_DIR) then
          next if (filename == __FILE__)
          name = filename[EZUP_LIB_DIR.length..-1]
          name.sub!(/\.rb$/, '')
          @include_libraries << LibraryPair.new("ezup/#{name}", filename)
        else
          for lib_dir in @include_path
            lib_dir += File::SEPARATOR
            if (filename.start_with? lib_dir) then
              name = filename[lib_dir.length..-1]
              name.sub!(/\.rb$/, '')
              @include_libraries << LibraryPair.new(name, filename)
            end
          end
        end

        self
      end
    end

    ParsedData = Struct.new(:shebang, :header, :body)

    def parse(src)
      data = ParsedData.new(nil, [], [])
      state = :shebang

      for line in src
        case (state)
        when :shebang
          if (line =~ /^#!/) then
            data.shebang = line
            state = :header
          elsif (line =~ /^#/) then
            data.header << line
            state = :header
          else
            data.body << line
            state = :body
          end
        when :header
          if (line =~ /^#/) then
            data.header << line
          else
            data.body << line
            state = :body
          end
        when :body
          data.body << line
        else
          raise "unknown parser state: #{state}"
        end
      end

      data
    end

    CGI_ERB = File.join(File.dirname(__FILE__), 'cgi.erb')

    class CGIContext
      def initialize(c)
        @c = c
      end
    end

    def make_cgi_builtin_code
      c = { :embedded_libraries => %w[ ezup ] + @include_libraries.map{|i| i.name } }
      erb = ERB.new(IO.read(CGI_ERB, opt: { :encoding => Encoding::UTF_8 }))
      erb.result(CGIContext.new(c).instance_eval{ binding })
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
