require 'grok-pure'

module Fluent
  class TextParser
    class GrokPure < Parser
      include TypeConverter

      Plugin.register_parser('grok_pure', self)

      config_param :time_format, :string, :default => nil
      config_param :time_key, :string, :default => 'time'
      config_param :grok_pattern, :string, :default => nil
      config_param :grok_pattern_path, :string, :default => nil

      class PatternError < ParserError; end

      def initialize
        super
        @mutex = Mutex.new
        @grok = Grok.new
        @grok.logger = LogProxy.new($log)
        @parsers = []
      end

      def configure(conf)
        super

        @time_parser = TimeParser.new(@time_format)

        if @grok_pattern_path
          Dir["#{@grok_pattern_path}/*"].sort.each do |f|
            @grok.add_patterns_from_file(f)
          end
        end

        begin
          if @conf['grok_pattern']
            @parsers << @grok.compile(@grok_pattern, true)
          else
            grok_confs = @conf.elements.select {|e| e.name == 'grok'}
            grok_confs.each do |grok_conf|
              @parsers << @grok.compile(@grok_pattern, true)
            end
          end
        rescue Grok::PatternError => e
          raise PatternError, e.message
        end
      end

      def parse(text)
        @parsers.each do |parser|
          time = nil
          record = {}

          matched = @parser.match_and_capture(text) do |k,v|
            if k == @time_key
              time = @mutex.synchronize { @time_parser.parse(v) }
            else
              record[k] = @type_converters.nil? ? v : convert_type(k,v)
            end
          end

          if matched
            time ||= Engine.now if @estimate_current_event
            yield time, record
          end
        end
        yield nil, nil
      end

      class LogProxy
        def initialize(logger)
          @logger = logger
        end

        def method_missing(sym, *args, &block)
          @logger.send(sym, *args, &block)
        end

        %w(debug info warn error fatal).each do |name|
          define_method("#{name}?".to_sym) { true }
        end
      end
    end
  end
end
