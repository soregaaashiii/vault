class SystemSettingsController < ApplicationController
  before_action :require_service_admin

  def show
    @settings = {
      "ocr_provider" => SystemSetting.get("ocr_provider") || ENV.fetch("BUSINESS_CARD_OCR_PROVIDER", "local_vision"),
      "google_cloud_vision_api_key_configured" => GoogleCloudVisionOcr.configured_api_key.present?,
      "billing_mode" => SystemSetting.get("billing_mode") || "not_configured",
      "system_notice" => SystemSetting.get("system_notice").to_s
    }
  end

  def update
    SystemSetting.set("ocr_provider", params[:ocr_provider])
    SystemSetting.set("google_cloud_vision_api_key", params[:google_cloud_vision_api_key]) if params[:google_cloud_vision_api_key].present?
    SystemSetting.set("billing_mode", params[:billing_mode])
    SystemSetting.set("system_notice", params[:system_notice])
    redirect_to system_settings_path, notice: "設定を更新しました"
  end

  private

  def require_service_admin
    return if service_admin?

    deny_access("システム設定はservice_adminのみ操作できます")
  end
end
