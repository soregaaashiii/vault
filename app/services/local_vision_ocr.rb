require "open3"
require "timeout"

class LocalVisionOcr
  SCRIPT_PATH = Rails.root.join("lib/ocr/recognize_text.swift")

  def extract_text(upload)
    cache_path = Rails.root.join("tmp/swift-module-cache")
    FileUtils.mkdir_p(cache_path)
    env = {
      "HOME" => Rails.root.join("tmp").to_s,
      "CLANG_MODULE_CACHE_PATH" => cache_path.to_s,
      "SWIFT_MODULE_CACHE_PATH" => cache_path.to_s
    }
    stdout, stderr, status = Timeout.timeout(15) do
      Open3.capture3(env, "/usr/bin/swift", SCRIPT_PATH.to_s, upload.tempfile.path)
    end
    raise "OCRに失敗しました: #{stderr.presence || 'unknown error'}" unless status.success?

    stdout.encode("UTF-8", invalid: :replace, undef: :replace).strip
  rescue Timeout::Error
    raise "OCRがタイムアウトしました"
  end
end
