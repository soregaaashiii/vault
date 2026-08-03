class BusinessCardParser
  EMAIL_PATTERN = /[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}/i
  PHONE_PATTERN = /(?:\+?\d[\d\-()\s]{7,}\d)/
  COMPANY_WORDS = /(株式会社|有限会社|合同会社|Inc\.?|Co\.?|Ltd\.?|Corporation|LLC|会社)/
  POSITION_WORDS = /(代表|取締役|部長|課長|係長|主任|営業|開発|Manager|Director|CEO|CTO|CFO)/i

  def self.parse(text)
    new(text).parse
  end

  def initialize(text)
    @text = text.to_s.encode("UTF-8", invalid: :replace, undef: :replace)
  end

  def parse
    lines = text.lines.map { |line| normalize(line) }.reject(&:blank?)
    email = text[EMAIL_PATTERN]
    phone = lines.lazy.map { |line| line[PHONE_PATTERN]&.squish }.find(&:present?)
    company_name = lines.find { |line| line.match?(COMPANY_WORDS) }
    position = lines.find { |line| line.match?(POSITION_WORDS) && line != company_name }
    name = guess_name(lines, email, phone, company_name, position)

    {
      name: name.presence || "名称未読取",
      email:,
      phone:,
      position:,
      company_name:,
      raw_text: text
    }
  end

  private

  attr_reader :text

  def normalize(line)
    line.to_s.tr("　", " ").squish
  end

  def guess_name(lines, email, phone, company_name, position)
    excluded = [ email, phone, company_name, position ].compact
    candidates = lines.reject do |line|
      excluded.include?(line) ||
        line.match?(EMAIL_PATTERN) ||
        line.match?(PHONE_PATTERN) ||
        line.match?(COMPANY_WORDS) ||
        line.match?(%r{https?://|www\.}i) ||
        line.match?(/[〒@]/)
    end

    candidates.find { |line| line.match?(/\p{Han}|\p{Hiragana}|\p{Katakana}/) && line.length <= 20 } ||
      candidates.find { |line| line.split.size.between?(2, 4) && line.length <= 40 }
  end
end
