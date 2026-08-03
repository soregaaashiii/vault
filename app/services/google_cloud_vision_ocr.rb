require "base64"
require "json"
require "net/http"
require "uri"

class GoogleCloudVisionOcr
  ENDPOINT = "https://vision.googleapis.com/v1/images:annotate"

  def self.configured_api_key
    if ActiveRecord::Base.connection.data_source_exists?("system_settings")
      SystemSetting.get("google_cloud_vision_api_key").presence || ENV["GOOGLE_CLOUD_VISION_API_KEY"]
    else
      ENV["GOOGLE_CLOUD_VISION_API_KEY"]
    end
  end

  def initialize(api_key: self.class.configured_api_key)
    @api_key = api_key
  end

  def extract_text(upload)
    raise "GOOGLE_CLOUD_VISION_API_KEYを設定してください" if api_key.blank?

    upload.tempfile.rewind
    response = post_json(payload(Base64.strict_encode64(upload.tempfile.read)))
    body = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      message = body.dig("error", "message") || response.message
      raise "Google Cloud Vision OCRに失敗しました: #{message}"
    end

    first = body.fetch("responses", []).first || {}
    raise "Google Cloud Vision OCRに失敗しました: #{first.dig('error', 'message')}" if first["error"].present?

    first.dig("fullTextAnnotation", "text").presence ||
      first.fetch("textAnnotations", []).first&.fetch("description", nil).to_s
  rescue JSON::ParserError
    raise "Google Cloud Vision OCRの応答を解析できませんでした"
  end

  private

  attr_reader :api_key

  def post_json(body)
    uri = URI("#{ENDPOINT}?key=#{api_key}")
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(body)

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 20, open_timeout: 10) do |http|
      http.request(request)
    end
  end

  def payload(encoded_image)
    {
      requests: [
        {
          image: { content: encoded_image },
          features: [
            { type: "DOCUMENT_TEXT_DETECTION", maxResults: 1 }
          ],
          imageContext: {
            languageHints: %w[ja en]
          }
        }
      ]
    }
  end
end
