module FakeWeb
  class Registry #:nodoc:
    include Singleton

    attr_accessor :uri_map

    def initialize
      clean_registry
    end

    def clean_registry
      self.uri_map = Hash.new { |hash, key| hash[key] = {} }
    end

    def register_uri(method, uri, options)
      uri_map[normalize_uri(uri)][method] = [*[options]].flatten.collect do |option|
        FakeWeb::Responder.new(method, uri, option, option[:times])
      end
    end

    def registered_uri?(method, uri)
      normalized_uri = normalize_uri(uri)
      !responses_for(method, uri).empty?
    end

    def response_for(method, uri, &block)
      responses = responses_for(method, uri)
      return nil if responses.empty?

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


    private

    def responses_for(method, uri)
      uri = normalize_uri(uri)

      if uri_map[uri].has_key?(method)
        uri_map[uri][method]
      elsif uri_map[uri].has_key?(:any)
        uri_map[uri][:any]
      elsif uri_map_matches?(method, uri)
        uri_map_matches(method, uri)
      elsif uri_map_matches(:any, uri)
        uri_map_matches(:any, uri)
      else
        []
      end
    end

    def uri_map_matches?(method, uri)
      !uri_map_matches(method, uri).nil?
    end

    def uri_map_matches(method, uri)
      uri = normalize_uri(uri.to_s).to_s
      uri = Utility.strip_default_port_from_uri(uri)

      matches = uri_map.select { |registered_uri, method_hash|
        registered_uri.is_a?(Regexp) && uri.match(registered_uri) && method_hash.has_key?(method)
      }

      if matches.size > 1
        raise MultipleMatchingRegexpsError,
          "More than one regular expression matched this request: #{method.to_s.upcase} #{uri}"
      end

      matches.map { |_, method_hash| method_hash[method] }.first
    end

    def normalize_uri(uri)
      return uri if uri.is_a?(Regexp)
      normalized_uri =
        case uri
        when URI then uri
        when String
          uri = 'http://' + uri unless uri.match('^https?://')
          URI.parse(uri)
        end
      normalized_uri.query = sort_query_params(normalized_uri.query)
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
