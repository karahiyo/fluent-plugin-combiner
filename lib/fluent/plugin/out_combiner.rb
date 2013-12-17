module Fluent
  class CombinerOutput < Fluent::Output
    Fluent::Plugin.register_output('combiner', self)

    # config_param :hoge, :string, :default => 'hoge'
    config_param :tag, :string, :default => nil
    config_param :tag_prefix, :string, :default => 'combined'
    config_param :input_tag_remove_prefix, :string, :default => nil
    config_param :count_interval, :time, :default => 60
    config_param :count_key, :string, :default => 'keys'
    config_param :bin_num, :integer, :default => 100

    attr_accessor :counts
    attr_accessor :tick, :bin_num

    def initialize
      super
      require 'pathname'
    end

    def configure(conf)
      super

      @tick = @count_interval.to_i if @count_interval
      @tag_str = @tag + '.' if @tag
      @tag_prefix_string = @tag_prefix + '.' if @tag_prefix
      if @input_tag_remove_prefix
        @remove_prefix_string = @input_tag_remove_prefix + '.' 
        @remove_prefix_length = @remove_prefix_string.length
      end

      @counts = initialize_counts
    end

    ## Fluent::Output main methods
    def start
      super
      start_watch
    end

    def shutdown
      super
      @watcher.terminate
      @watcher.join
    end

    def flush
      flushed, @counts = @counts, initialize_counts(@counts.keys.dup)
      generate_output(flushed)
    end

    def flush_emit
      flushed = flush
      now = Fluent::Engine.now
      flushed.each do |tag, message|
        Fluent::Engine.emit(tag, now, message)
      end
    end

    def generate_output(data)
      output = {}
      data.each do |tag, hist|
        if @tag
          output[@tag] = hist
        else
          output[add_prefix(stripped_tag(tag))] = hist
        end
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


    ## Combiner's main methods
    def initialize_counts(tags=nil)
      counts = {}
      if tags
        tags.each do |tag|
          counts[tag] = {:hist => {}, :sum => 0, :len => 0}
        end
      end
      counts
    end


    def increment(tag, key)
      @counts[tag] ||= {:hist => {}, :sum => 0, :len => 0}
      if @counts[tag][:hist].key? key
        @counts[tag][:hist][key] += 1
        @counts[tag][:sum] += 1
      else
        @counts[tag][:hist][key] = 1
        @counts[tag][:sum] += 1
        @counts[tag][:len] += 1
      end
      @counts
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

    ## Utils
    def add_prefix(tag="")
      return @tag_prefix if tag.empty?
      return @tag_prefix_string + tag
    end

    def stripped_tag(tag)
      return tag unless @input_tag_remove_prefix
      return tag[@remove_prefix_length..-1] if tag.start_with?(@remove_prefix_string) && tag.length > @remove_prefix_length
      return "" if tag == @input_tag_remove_prefix
      return tag
    end

    private

    ## watcher
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
