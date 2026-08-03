class Contact < ApplicationRecord
  include Archivable

  belongs_to :organization
  belongs_to :company, optional: true
  belongs_to :created_by, class_name: "User", optional: true, inverse_of: :created_contacts
  has_many :business_cards, dependent: :restrict_with_error
  has_many :contact_notes, dependent: :restrict_with_error

  validates :name, presence: true
  validate :company_must_belong_to_organization

  scope :search, ->(query) {
    return all if query.blank?

    term = "%#{sanitize_sql_like(query)}%"
    left_joins(:company).where(
      "contacts.name LIKE :term OR contacts.email LIKE :term OR contacts.phone LIKE :term OR contacts.position LIKE :term OR companies.name LIKE :term",
      term:
    )
  }

  scope :accessible_to, ->(user) {
    user&.service_admin? ? all : where(organization_id: user&.organization_id)
  }

  def duplicate_candidates
    scope = organization.contacts.active.where.not(id:)
    if email.present?
      scope.where("lower(email) = ?", email.downcase)
    else
      scope.where(name:, company_id:)
    end
  end

  def editable_by?(user)
    return true if user&.service_admin?
    return false unless organization_id == user&.organization_id
    return true if user.org_admin?

    created_by_id == user.id
  end

  def restorable_by?(user)
    user&.service_admin? || (user&.org_admin? && organization_id == user.organization_id)
  end

  private

  def company_must_belong_to_organization
    return if company.blank? || company.organization_id == organization_id

    errors.add(:company, "must belong to the same organization")
  end
end
