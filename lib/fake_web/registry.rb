module FakeWeb
  class Registry #:nodoc:
    include Singleton

    attr_accessor :uri_map

    def initialize
      clean_registry
    end

    def clean_registry
      self.uri_map = Hash.new do |hash, key|
        hash[key] = Hash.new(&hash.default_proc)
      end
    end

    def register_uri(method, uri, options)
      uri_map[normalize_uri(uri)][method] = [*[options]].flatten.collect do |option|
        FakeWeb::Responder.new(method, uri, option, option[:times])
      end
    end

    def registered_uri?(method, uri)
      normalized_uri = normalize_uri(uri)
      uri_map[normalized_uri].has_key?(method) || uri_map[normalized_uri].has_key?(:any)
    end

    def registered_uri(method, uri)
      uri = normalize_uri(uri)
      registered = registered_uri?(method, uri)
      if registered && uri_map[uri].has_key?(method)
        uri_map[uri][method]
      elsif registered
        uri_map[uri][:any]
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

    private

    def normalize_uri(uri)
      case uri
      when URI then uri
      else
        uri = 'http://' + uri unless uri.match('^https?://')
        parsed_uri = URI.parse(uri)
        parsed_uri.query = sort_query_params(parsed_uri.query)
        parsed_uri
      end
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