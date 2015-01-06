require 'grok-pure'

module Fluent
  class TextParser
    class GrokPure < Parser
      include TypeConverter

      Plugin.register_parser('grok_pure', self)

      config_param :time_format, :string, :default => nil
      config_param :time_key, :string, :default => 'time'
      config_param :grok_pattern, :string
      config_param :grok_pattern_path, :string, :default => nil

      unless method_defined?(:log)
        define_method(:log) { $log }
      end

      class PatternError < ParserError; end

      def initialize
        super
        @time_parser = TimeParser.new(@time_format)
        @mutex = Mutex.new
        @grok = Grok.new
      end

      def configure(conf)
        super

        if @grok_pattern_path
          Dir["#{@grok_pattern_path}/*"].sort.each do |f|
            @grok.add_patterns_from_file(f)
          end
        end

        begin
          @grok.compile(@grok_pattern, true)
        rescue Grok::PatternError => e
          raise PatternError, e.message
        end
      end

      def parse(text)
        time = nil
        record = {}

        matched = @grok.match_and_capture(text) do |k,v|
          if k == @time_key
            time = @mutex.synchronize { @time_parser.parse(v) }
          else
            record[k] = @type_converters.nil? ? v : convert_type(k,v)
          end
        end

        if matched
          time ||= Engine.now if @estimate_current_event
          yield time, record
        else
          yield nil, nil
        end

      end
    end
  end
end
