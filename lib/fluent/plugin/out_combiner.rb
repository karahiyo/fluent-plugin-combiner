module Fluent
  class CombinerOutput < Fluent::Output
    Fluent::Plugin.register_output('combiner', self)

    # config_param :hoge, :string, :default => 'hoge'

    def initialize
      super
      require 'pathname'
    end

    def configure(conf)
      super
      initialize_hist
    end

    def initialize_hist
      @sum = 0
      @length = 0
      @hist = {}
    end

    def start
      super
    end

    def shutdown
      super
    end

    def increment(key)
      if @hist.key? key
        @hist[key] += 1
        @sum += 1
      else
        @hist[key] = 1
        @sum += 1
        @length += 1
      end
    end

    def clear
      initialize_hist
    end

    def flush
      data = {}
      data["hist"] = @hist
      data["sum"] = @sum
      data["length"] = @length
      initialize_hist
      data
    end

    def emit(tag, es, chain)

      data = {}
      data["hist"] = @hist
      es.each do |time, record|
        increment(record)
      end

      chain.next
    end

  end 
end
