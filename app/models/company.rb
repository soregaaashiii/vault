class Company < ApplicationRecord
  include Archivable

  belongs_to :organization
  belongs_to :created_by, class_name: "User", optional: true, inverse_of: :created_companies
  has_many :contacts, dependent: :restrict_with_error

  validates :name, presence: true

  scope :search, ->(query) {
    return all if query.blank?

    term = "%#{sanitize_sql_like(query)}%"
    where("name LIKE :term OR website LIKE :term OR phone LIKE :term OR address LIKE :term", term:)
  }

  scope :accessible_to, ->(user) {
    user&.service_admin? ? all : where(organization_id: user&.organization_id)
  }

  def duplicate_candidates
    organization.companies.active.where.not(id:).where("lower(name) = ?", name.to_s.downcase)
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
end
