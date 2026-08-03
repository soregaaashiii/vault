class TrashController < ApplicationController
  before_action :require_admin

  def index
    archived_notes = ContactNote
      .where(organization_id: scoped_organizations.select(:id))
      .archived
      .visible_to(current_user)
    archived_cards = scoped_business_cards.archived
    person_ids = (
      scoped_contacts.archived.pluck(:id) +
      archived_cards.distinct.pluck(:contact_id) +
      archived_notes.distinct.pluck(:contact_id) +
      scoped_contacts.joins(:company).merge(scoped_companies.archived).pluck(:id)
    ).uniq

    @contacts = scoped_contacts
      .where(id: person_ids)
      .includes(:company, business_cards: { image_attachment: :blob }, contact_notes: :user)
      .order(:name)

    @hidden_notes_by_contact_id = archived_notes.includes(:user).order(archived_at: :desc).group_by(&:contact_id)
    @hidden_cards_by_contact_id = archived_cards.with_attached_image.order(archived_at: :desc).group_by(&:contact_id)
  end

  private

  def require_admin
    return if service_admin? || org_admin?

    deny_access("非表示一覧を見る権限がありません")
  end
end
