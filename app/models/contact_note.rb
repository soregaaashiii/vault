class ContactNote < ApplicationRecord
  include Archivable

  VISIBILITIES = %w[shared personal].freeze

  belongs_to :organization
  belongs_to :contact
  belongs_to :user

  validates :body, :visibility, presence: true
  validates :visibility, inclusion: { in: VISIBILITIES }
  validate :associations_must_belong_to_organization

  scope :visible_to, ->(user) {
    return all if user&.service_admin?

    where(visibility: "shared").or(where(visibility: "personal", user:))
  }

  scope :accessible_to, ->(user) {
    user&.service_admin? ? all : where(organization_id: user&.organization_id)
  }

  def editable_by?(actor)
    return true if actor&.service_admin?
    return false unless organization_id == actor&.organization_id
    return true if actor.org_admin?

    user_id == actor.id
  end

  def restorable_by?(actor)
    actor&.service_admin? || (actor&.org_admin? && organization_id == actor.organization_id)
  end

  private

  def associations_must_belong_to_organization
    errors.add(:contact, "must belong to the same organization") if contact.present? && contact.organization_id != organization_id
    errors.add(:user, "must belong to the same organization") if user.present? && user.organization_id != organization_id && !user.service_admin?
  end
end
