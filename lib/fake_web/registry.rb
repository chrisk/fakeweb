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

      uri_map_matches(method, uri, URI) ||
      uri_map_matches(:any,   uri, URI) ||
      uri_map_matches(method, uri, Regexp) ||
      uri_map_matches(:any,   uri, Regexp) ||
      []
    end

    def uri_map_matches(method, uri, type_to_check = URI)
      uris_to_check = variations_of_uri_as_strings(uri)

      matches = uri_map.select { |registered_uri, method_hash|
        registered_uri.is_a?(type_to_check) && method_hash.has_key?(method)
      }.select { |registered_uri, method_hash|
        if type_to_check == URI
          uris_to_check.include?(registered_uri.to_s)
        elsif type_to_check == Regexp
          uris_to_check.any? { |u| u.match(registered_uri) }
        end
      }

      if matches.size > 1
        raise MultipleMatchingURIsError,
          "More than one registered URI matched this request: #{method.to_s.upcase} #{uri}"
      end

      matches.map { |_, method_hash| method_hash[method] }.first
    end


    def variations_of_uri_as_strings(uri_object)
      uris = []
      normalized_uri = normalize_uri(uri_object)

      # all orderings of query parameters
      query = normalized_uri.query
      if query.nil? || query.empty?
        uris << normalized_uri
      else
        FakeWeb::Utility.simple_array_permutation(query.split('&')) do |p|
          current_permutation = normalized_uri.dup
          current_permutation.query = p.join('&')
          uris << current_permutation
        end
      end

      uri_strings = uris.map { |uri| uri.to_s }

      # including and omitting the default port
      if normalized_uri.default_port == normalized_uri.port
        uri_strings += uris.map { |uri|
          uri.to_s.sub(/#{Regexp.escape(normalized_uri.request_uri)}$/,
                       ":#{normalized_uri.port}#{normalized_uri.request_uri}")
        }
      end

      uri_strings
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
