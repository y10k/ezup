# -*- coding: utf-8 -*-
# CGI compiler

module EasyUp
  class Compiler
    EZUP_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + File::SEPARATOR

    def initialize
      @include_path = []
      @include_libraries = []
    end

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
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
