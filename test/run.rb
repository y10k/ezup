#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

$:.unshift File.join(File.dirname($0))
$:.unshift File.join(File.dirname($0), '..', 'lib')

mask = //                       # any match
if ($0 == __FILE__) then
  if (ARGV.length > 0 && ARGV[0] !~ /^-/) then
    mask = Regexp.compile(ARGV.shift)
  end
end

test_dir, this_name = File.split(__FILE__)
for test_rb in Dir.entries(test_dir).sort
  case (test_rb)
  when this_name
    # skip
  when /^test_.*\.rb$/
    if (test_rb =~ mask) then
      puts "load #{test_rb}"
      require File.join(test_dir, test_rb)
    end
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
