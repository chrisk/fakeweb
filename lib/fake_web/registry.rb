module FakeWeb
  class Registry #:nodoc:
    include Singleton

    attr_accessor :uri_map, :pattern_map

    def initialize
      clean_registry
    end

    def clean_registry
      self.uri_map = Hash.new do |hash, key|
        hash[key] = Hash.new(&hash.default_proc)
      end
      self.pattern_map = []
    end

    def register_uri(method, uri, options)
      case uri
      when String
        uri_map[normalize_uri(uri)][method] = [*[options]].flatten.collect do |option|
          FakeWeb::Responder.new(method, uri, option, option[:times])
        end
      when Regexp
        responders = [*[options]].flatten.collect do |option|
          FakeWeb::Responder.new(method, uri, option, option[:times])
        end
        pattern_map << {:pattern => uri,
                        :responders => responders,
                        :method => method }

      end
    end

    def registered_uri?(method, uri)
      normalized_uri = normalize_uri(uri)
      uri_map[normalized_uri].has_key?(method) || uri_map[normalized_uri].has_key?(:any) || pattern_map_matches?(method, uri) || pattern_map_matches?(:any, uri)
    end

    def registered_uri(method, uri)
      uri = normalize_uri(uri)
      registered = registered_uri?(method, uri)
      if registered && uri_map[uri].has_key?(method)
        uri_map[uri][method]
      elsif registered && pattern_map_matches?(method, uri)
        pattern_map_matches(method, uri).map{|m| m[:responders]}.flatten
      elsif registered && uri_map[uri].has_key?(:any)
        uri_map[uri][:any]
      elsif registered && pattern_map_matches(:any, uri)
        pattern_map_matches(:any, uri).map{|m| m[:responders]}.flatten
      else
        nil
      end
    end

    def response_for(method, uri, &block)
      responses = registered_uri(method, uri)
      return nil if responses.nil?

      next_response = responses.last
      responses.each do |response|
        if response.times and response.times > 0
          response.times -= 1
          next_response = response
          break
        end
      end

      next_response.response(&block)
    end

    def pattern_map_matches?(method, uri)
      !pattern_map_matches(method, uri).empty?
    end

    def pattern_map_matches(method, uri)
      uri = uri.to_s.sub(/:(80|443)/, "")
      pattern_map.select { |p| uri.match(p[:pattern]) && p[:method] == method }
    end

    def pattern_map_match(method, uri)
      pattern_map_matches(method, uri).first
    end

    private

    def normalize_uri(uri)
      normalized_uri =
        case uri
        when URI then uri
        when String
          uri = 'http://' + uri unless uri.match('^https?://')
          parsed_uri = URI.parse(uri)
          parsed_uri.query = sort_query_params(parsed_uri.query)
          parsed_uri
        end
      normalized_uri.normalize
    end

    def sort_query_params(query)
      if query.nil? || query.empty?
        nil
      else
        query.split('&').sort.join('&')
      end
    end

  end
end
