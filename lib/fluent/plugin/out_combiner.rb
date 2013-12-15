module Fluent
  class CombinerOutput < Fluent::Output
    Fluent::Plugin.register_output('combiner', self)

    # config_param :hoge, :string, :default => 'hoge'
    config_param :tag, :string, :default => 'combined'
    config_param :tag_prefix, :string, :default => nil
    config_param :input_tag_remove_prefix, :string, :default => nil
    config_param :count_interval, :time, :default => 60
    config_param :count_key, :string, :default => 'keys'

    attr_accessor :hist
    attr_accessor :tick, :last_checked

    def initialize
      super
      require 'pathname'
    end

    def configure(conf)
      super

      if @count_interval
        @tick = @count_interval.to_i
      end

      @hist = initialize_hist
    end

    def initialize_hist(tags=nil)
      hist = {}
      if tags
        tags.each do |tag|
          hist[tag] = {:hist => {}, :sum => 0, :len => 0}
        end
      end
      hist
    end

    def start
      super
      start_watch
    end

    def shutdown
      super
      @watcher.terminate
      @watcher.join
    end

    def increment(tag, key)
      @hist[tag] ||= {:hist => {}, :sum => 0, :len => 0}
      if @hist[tag][:hist].key? key
        @hist[tag][:hist][key] += 1
        @hist[tag][:sum] += 1
      else
        @hist[tag][:hist][key] = 1
        @hist[tag][:sum] += 1
        @hist[tag][:len] += 1
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
      @hist = initialize_hist(@hist.keys.dup)
    end

    def flush
      flushed, @hist = @hist, initialize_hist(@hist.keys.dup)
      generate_output(flushed)
    end

    def flush_emit
      flushed = flush
      Fluent::Engine.emit(@tag,  Fluent::Engine.now,  flushed)
    end

    def generate_output(data)
      output = {}
      data.each do |tag, hist|
        output[@tag + '.' + tag] = hist
      end
      output
    end

    def emit(tag, es, chain)

      es.each do |time, record|
        keys = record[@count_key]
        countup(tag, keys)
      end

      chain.next
    end

    private
    def start_watch
      @watcher = Thread.new(&method(:watch))
    end

    def watch
      @last_checked = Fluent::Engine.now
      while true
        sleep 0.5
        if Fluent::Engine.now - @last_checked >= @tick
          now = Fluent::Engine.now
          flush_emit
          @last_checked = now
        end
      end
    end

  end 
end
