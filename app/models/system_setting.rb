class SystemSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key)
    find_by(key:)&.value
  end

  def self.set(key, value)
    record = find_or_initialize_by(key:)
    record.value = value
    record.save!
  end
end
