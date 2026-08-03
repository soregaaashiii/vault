class Organization < ApplicationRecord
  include Archivable

  has_many :users, dependent: :restrict_with_error
  has_many :companies, dependent: :restrict_with_error
  has_many :contacts, dependent: :restrict_with_error
  has_many :business_cards, dependent: :restrict_with_error
  has_many :contact_notes, dependent: :restrict_with_error

  validates :name, presence: true

  scope :accessible_to, ->(user) {
    user&.service_admin? ? all : where(id: user&.organization_id)
  }

  def manageable_by?(user)
    user&.service_admin?
  end
end
