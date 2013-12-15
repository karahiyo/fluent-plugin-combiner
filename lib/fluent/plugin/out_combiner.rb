module Fluent
  class CombinerOutput < Fluent::Output
    Fluent::Plugin.register_output('combiner', self)

    # config_param :hoge, :string, :default => 'hoge'
    config_param :tag, :string, :default => 'combined'
    config_param :tag_prefix, :string, :default => nil
    config_param :input_tag_remove_prefix, :string, :default => nil

    attr_accessor :hist

    def initialize
      super
      require 'pathname'
    end

    def configure(conf)
      super
      @hist = initialize_hist
    end

    def initialize_hist
      if @hist
        @hist.each do |tag, hist|
          @hist[tag] = {"hist" => {}, "sum" => 0, "length" => 0}
        end
      else
        {}
      end
    end

    #def start
    #  super
    #end

    #def shutdown
    #  super
    #end

    def increment(tag, key)
      @hist[tag] ||= {"hist" => {}, "sum" => 0, "length" => 0}
      if @hist[tag]["hist"].key? key
        @hist[tag]["hist"][key] += 1
        @hist[tag]["sum"] += 1
      else
        @hist[tag]["hist"][key] = 1
        @hist[tag]["sum"] += 1
        @hist[tag]["length"] += 1
      end
      @hist
    end

    def countup(tag, keys)
      if keys.is_a?(Array) 
        keys.each {|k| increment(tag, k)}
      elsif keys.is_a?(String)
        increment(tag, keys)
      end
    end

    def clear
      initialize_hist
    end

    def flush
      data = @hist.dup
      initialize_hist
      data
    end

    def emit(tag, es, chain)

      es.each do |time, record|
        keys = record["keys"]
        countup(tag, keys)
      end

      chain.next
    end

  end 
end
