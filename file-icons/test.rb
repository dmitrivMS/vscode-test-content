# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

class HttpClient
  DEFAULT_TIMEOUT = 10

  def initialize(base_url, headers: {})
    @base_uri = URI.parse(base_url)
    @headers = { "Content-Type" => "application/json" }.merge(headers)
  end

  def get(path, params = {})
    uri = build_uri(path, params)
    request = Net::HTTP::Get.new(uri, @headers)
    execute(uri, request)
  end

  def post(path, body = {})
    uri = build_uri(path)
    request = Net::HTTP::Post.new(uri, @headers)
    request.body = body.to_json
    execute(uri, request)
  end

  private

  def build_uri(path, params = {})
    uri = @base_uri.dup
    uri.path = path
    uri.query = URI.encode_www_form(params) unless params.empty?
    uri
  end

  def execute(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = DEFAULT_TIMEOUT
    response = http.request(request)
    JSON.parse(response.body, symbolize_names: true)
  end
end
