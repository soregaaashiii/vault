class BusinessCardOcr
  def self.extract_text(upload)
    provider.extract_text(upload)
  end

  def self.provider
    case configured_provider
    when "google_cloud_vision"
      GoogleCloudVisionOcr.new
    else
      LocalVisionOcr.new
    end
  end

  def self.configured_provider
    if ActiveRecord::Base.connection.data_source_exists?("system_settings")
      SystemSetting.get("ocr_provider").presence || ENV.fetch("BUSINESS_CARD_OCR_PROVIDER", "local_vision")
    else
      ENV.fetch("BUSINESS_CARD_OCR_PROVIDER", "local_vision")
    end
  end
end
