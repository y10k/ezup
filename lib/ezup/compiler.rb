# -*- coding: utf-8 -*-
# CGI compiler

require 'erb'
require 'fileutils'
require 'yaml'

module Kernel
  alias ezup_original_autoload autoload

  def autoload(const_name, feature)
    if (EasyUp::Compiler.autoload_expand) then
      require(feature)
    else
      ezup_original_autoload(const_name, feature)
    end
    nil
  end
end

class Module
  alias ezup_original_autoload autoload

  def autoload(const_name, feature)
    if (EasyUp::Compiler.autoload_expand) then
      require(feature)
    else
      ezup_original_autoload(const_name, feature)
    end
    nil
  end
end

module EasyUp
  class Compiler
    class << self
      attr_accessor :autoload_expand
    end
    self.autoload_expand = false

    EZUP_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + File::SEPARATOR

    def initialize
      @ruby = nil
      @rubygems = false
      @gem_home = nil
      @include_path = []
      @include_libraries = []
    end

    attr_accessor :ruby
    attr_accessor :rubygems
    attr_accessor :gem_home
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
      c = {
        :rubygems => @rubygems,
        :gem_home => @gem_home,
        :embedded_libraries => %w[ ezup ] + @include_libraries.map{|i| i.name }
      }
      erb = ERB.new(IO.read(CGI_ERB, opt: { :encoding => Encoding::UTF_8 }))
      erb.result(CGIContext.new(c).instance_eval{ binding })
    end

    def compile(dst, src)
      data = parse(src)

      if (@ruby) then
        dst << "#!#{@ruby}\n"
      elsif (data.shebang) then
        dst << data.shebang
      end

      for line in data.header
        dst << line
      end

      dst << "\n\n"
      dst << "## EZUP_CGI_BUILTIN_CODE\n"
      dst << "\n"
      dst << make_cgi_builtin_code
      dst << "\n"

      for lib_pair in @include_libraries
        dst << "## EZUP_INCLUDE_LIBRARY: #{lib_pair.name}\n"
        dst << "\n"
        dst << IO.read(lib_pair.path, opt: { :encoding => Encoding::UTF_8 })
        dst << "\n"
      end

      dst << "## EZUP_MAIN\n"
      dst << "\n"
      for line in data.body
        dst << line
      end
    end

    def self.run(argv=ARGV)
      filename = ARGV.shift or raise 'need for source code to compile.'
      base_dir = File.dirname(filename)
      name = File.basename(filename, '.rb')
      cgi_name = File.join(base_dir, "#{name}.cgi")
      config_yml = File.join(base_dir, 'config.yml')

      cc = Compiler.new
      if (File.exist? config_yml) then
        conf = YAML.load_file(config_yml)
        cc.ruby = conf['ruby'] if (conf.key? 'ruby')
        cc.rubygems = conf['rubygems'] ? true : false
        cc.gem_home = conf['gem_home'] if (conf.key? 'gem_home')
        if (conf.key? 'include_path') then
          for lib_dir in conf['include_path']
            $: << File.expand_path(lib_dir)
            cc.add_include_path(lib_dir)
          end
        end
      end

      EasyUp::Compiler.autoload_expand = conf['autoload_expand'] ? true : false
      load(File.expand_path(filename))
      cc.scan_include_libraries

      File.open(cgi_name, 'w:utf-8') {|write_io|
        File.open(filename, 'r:utf-8') {|read_io|
          cc.compile(write_io, read_io)
        }
      }

      FileUtils.chmod(0755, cgi_name)
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
