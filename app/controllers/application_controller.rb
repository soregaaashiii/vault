class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login
  helper_method :current_user, :current_organization, :service_admin?, :org_admin?, :member?

  private

  def current_user
    @current_user ||= User.active.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_organization
    current_user&.organization
  end

  def service_admin?
    current_user&.service_admin?
  end

  def org_admin?
    current_user&.org_admin?
  end

  def member?
    current_user&.member?
  end

  def require_login
    if current_user&.organization&.archived? && !current_user.service_admin?
      reset_session
      redirect_to new_session_path, alert: "Organizationが停止中です"
      return
    end

    return if current_user

    redirect_to new_session_path, alert: "ログインしてください"
  end

  def scoped_organizations
    return Organization.all if service_admin?

    Organization.active.where(id: current_organization&.id)
  end

  def scoped_companies
    Company.accessible_to(current_user)
  end

  def scoped_contacts
    Contact.accessible_to(current_user)
  end

  def scoped_business_cards
    BusinessCard.accessible_to(current_user)
  end

  def assign_current_organization(record)
    if service_admin? && record.respond_to?(:company) && record.company.present?
      record.organization = record.company.organization
    end
    record.organization ||= current_organization || Organization.first
  end

  def assign_creator(record)
    record.created_by ||= current_user if record.respond_to?(:created_by=)
  end

  def deny_access(message = "権限がありません")
    redirect_to root_path, alert: message
  end

  def ensure_editable!(record)
    return true if record.editable_by?(current_user)

    deny_access
    false
  end

  def ensure_restorable!(record)
    return true if record.restorable_by?(current_user)

    deny_access("復元する権限がありません")
    false
  end
end
