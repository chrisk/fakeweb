module FakeWeb
  class Responder #:nodoc:

    attr_accessor :method, :uri, :options, :times

    def initialize(method, uri, options, times)
      self.method = method
      self.uri = uri
      self.options = options
      self.times = times ? times : 1
    end

    def response(&block)
      if has_baked_response?
        response = baked_response
      else
        code, msg = meta_information
        response = Net::HTTPResponse.send(:response_class, code.to_s).new(uri, code.to_s, msg)
        response.instance_variable_set(:@body, content)
      end

      response.instance_variable_set(:@read, true)
      response.extend FakeWeb::Response

      optionally_raise(response)

      yield response if block_given?

      response
    end

    private

    def content
      [ :file, :string ].each do |map_option|
        next unless options.has_key?(map_option)
        return self.send("#{map_option}_response", options[map_option])
      end

      return ''
    end

    def file_response(path)
      IO.read(path)
    end

    def string_response(string)
      string
    end

    def baked_response
      resp = case options[:response]
      when Net::HTTPResponse then options[:response]
      when String
        socket = Net::BufferedIO.new(options[:response])
        r = Net::HTTPResponse.read_new(socket)

        # Store the oiriginal transfer-encoding
        saved_transfer_encoding = r.instance_eval {
          @header['transfer-encoding'] if @header.key?('transfer-encoding')
        }

        # read the body of response.
        r.instance_eval { @header['transfer-encoding'] = nil }
        r.reading_body(socket, true) {}

        # Delete the transfer-encoding key from r.@header if there wasn't one,
        # else restore the saved_transfer_encoding.
        if saved_transfer_encoding.nil?
          r.instance_eval { @header.delete('transfer-encoding') }
        else
          r.instance_eval { @header['transfer-encoding'] = saved_transfer_encoding }
        end
        r
      else raise StandardError, "Handler unimplemented for response #{options[:response]}"
      end
    end

    def has_baked_response?
      options.has_key?(:response)
    end

    def optionally_raise(response)
      return unless options.has_key?(:exception)
      ex_alloc = options[:exception].allocate
      ex_instance = case ex_alloc
      when Net::HTTPError, OpenURI::HTTPError
        options[:exception].new('Exception from FakeWeb', response)
      else options[:exception].new
      end
      raise ex_instance
    end

    def meta_information
      options.has_key?(:status) ? options[:status] : [200, 'OK']
    end

  end
end