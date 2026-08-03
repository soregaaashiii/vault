class BusinessCard < ApplicationRecord
  include Archivable

  belongs_to :organization
  belongs_to :contact
  belongs_to :created_by, class_name: "User", optional: true, inverse_of: :created_business_cards
  has_one_attached :image

  validates :image, presence: true
  validate :contact_must_belong_to_organization

  scope :search, ->(query) {
    return all if query.blank?

    term = "%#{sanitize_sql_like(query)}%"
    left_joins(contact: :company).where(
      "business_cards.label LIKE :term OR contacts.name LIKE :term OR contacts.email LIKE :term OR contacts.phone LIKE :term OR contacts.position LIKE :term OR companies.name LIKE :term",
      term:
    )
  }

  scope :accessible_to, ->(user) {
    user&.service_admin? ? all : where(organization_id: user&.organization_id)
  }

  def editable_by?(user)
    return true if user&.service_admin?
    return false unless organization_id == user&.organization_id
    return true if user.org_admin?

    created_by_id == user.id || contact.created_by_id == user.id
  end

  def restorable_by?(user)
    user&.service_admin? || (user&.org_admin? && organization_id == user.organization_id)
  end

  private

  def contact_must_belong_to_organization
    return if contact.blank? || contact.organization_id == organization_id

    errors.add(:contact, "must belong to the same organization")
  end
end
