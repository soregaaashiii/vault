class UsersController < ApplicationController
  before_action :require_user_admin
  before_action :set_user, only: %i[edit update archive restore]

  def index
    @users = User.accessible_to(current_user).order(:organization_id, :role, :name)
  end

  def new
    @user = User.new(role: default_role, organization: default_organization)
  end

  def edit
    deny_access unless @user.manageable_by?(current_user)
  end

  def create
    @user = User.new(user_params)
    @user.organization = current_organization if org_admin?
    @user.role = "member" if org_admin?

    if @user.manageable_by?(current_user) && @user.role_changeable_by?(current_user, @user.role) && @user.save
      redirect_to users_path, notice: "ユーザーを作成しました"
    else
      @user.errors.add(:base, "権限がありません") unless @user.errors.any?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless @user.manageable_by?(current_user)
      deny_access
      return
    end

    attrs = user_params
    attrs[:role] = "member" if org_admin?
    attrs.delete(:password) if attrs[:password].blank?
    attrs.delete(:password_confirmation) if attrs[:password_confirmation].blank?

    unless @user.role_changeable_by?(current_user, attrs[:role] || @user.role)
      deny_access("権限を変更できません")
      return
    end

    if @user.update(attrs)
      redirect_to users_path, notice: "ユーザーを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    unless @user.manageable_by?(current_user)
      deny_access
      return
    end

    @user.archive!
    redirect_to users_path, notice: "ユーザーを停止しました。登録済みデータはOrganizationの資産として残ります。"
  end

  def restore
    unless @user.manageable_by?(current_user)
      deny_access
      return
    end

    @user.restore!
    redirect_to users_path, notice: "ユーザーを復元しました"
  end

  private

  def require_user_admin
    return if service_admin? || org_admin?

    deny_access("ユーザー管理の権限がありません")
  end

  def set_user
    @user = User.accessible_to(current_user).find(params[:id])
  end

  def default_role
    service_admin? ? "org_admin" : "member"
  end

  def default_organization
    service_admin? ? Organization.active.first : current_organization
  end

  def user_params
    permitted = %i[name email password password_confirmation role organization_id]
    params.require(:user).permit(permitted)
  end
end
