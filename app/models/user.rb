class User < ApplicationRecord
  include Archivable

  ROLES = %w[service_admin org_admin member].freeze

  belongs_to :organization, optional: true
  has_many :created_companies, class_name: "Company", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :created_contacts, class_name: "Contact", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :created_business_cards, class_name: "BusinessCard", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :contact_notes, dependent: :restrict_with_error

  has_secure_password

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }
  validates :organization, presence: true, unless: :service_admin?

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  scope :accessible_to, ->(actor) {
    if actor&.service_admin?
      all
    else
      where(organization_id: actor&.organization_id).where.not(role: "service_admin")
    end
  }

  scope :manageable_to, ->(actor) {
    if actor&.service_admin?
      all
    elsif actor&.org_admin?
      where(organization_id: actor.organization_id, role: "member")
    else
      none
    end
  }

  def service_admin?
    role == "service_admin"
  end

  def org_admin?
    role == "org_admin"
  end

  def member?
    role == "member"
  end

  def manageable_by?(actor)
    return true if actor&.service_admin?
    return false unless actor&.org_admin?

    organization_id == actor.organization_id && member?
  end

  def role_changeable_by?(actor, new_role)
    return true if actor&.service_admin? && ROLES.include?(new_role)
    return true if actor&.org_admin? && organization_id == actor.organization_id && new_role == "member"

    false
  end
end
