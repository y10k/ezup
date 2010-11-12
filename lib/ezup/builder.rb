# -*- coding: utf-8 -*-
# Rack middleweare builder

module EasyUp
  class Builder
    def initialize
      @constructor = proc{|app| app }
    end

    def use(middleware, *args, &block)
      outer_constructor = @constructor
      @constructor = proc{|app|
        outer_constructor.call(middleware.new(app, *args, &block))
      }
      nil
    end

    def wrap_app(app)
      @constructor.call(app)
    end
  end

  if (defined? CGIRunner) then
    CGIRunner.top_level_builder = Builder.new
  end
end

# Local Variables:
# mode: Ruby
# indent-tabs-mode: nil
# End:
