module Tika
  # wrapper methods for https://wiki.apache.org/tika/TikaJAXRS

  def self.get_recursive_metadata(file)
    # The recursive metadata request is designed for embedded files and compressed files,
    # but we're using it as it is the only method that extracts both metadata and content
    # at once.
    response = client.post('/rmeta/form/text',
                           form: { upload: HTTP::FormData::File.new(file.path) })

    # Ensure we consume the response before making a new request
    # https://github.com/httprb/http/wiki/Persistent-Connections-(keep-alive)#note-using-persistent-requests-correctly
    body = response.to_s
    raise TikaError, "Parsing failure: #{response.status}" unless response.status == 200

    JSON.parse(body)
  end

  def self.tika_version
    response = client.get('/version')
    raise TikaError, "Failed to retrieve version: #{response.status}" unless response.status == 200

    response.to_s.split.last.to_f
  end

  def self.host
    ENV.fetch('TIKA_HOST')
  end

  def self.port
    ENV.fetch('TIKA_PORT')
  end

  def self.client
    @tika_client ||= HTTP.persistent "http://#{host}:#{port}"
  end

  private_class_method :host, :port, :client
end

class TikaError < StandardError; end
