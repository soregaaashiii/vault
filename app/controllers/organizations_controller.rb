class OrganizationsController < ApplicationController
  before_action :require_service_admin
  before_action :set_organization, only: %i[edit update archive restore destroy_as_archive]

  def index
    @organizations = Organization.order(:name)
  end

  def new
    @organization = Organization.new
  end

  def edit
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      redirect_to organizations_path, notice: "Organizationを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update(organization_params)
      redirect_to organizations_path, notice: "Organizationを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @organization.archive!
    redirect_to organizations_path, notice: "Organizationを停止しました"
  end

  def restore
    @organization.restore!
    redirect_to organizations_path, notice: "Organizationを復元しました"
  end

  def destroy_as_archive
    @organization.archive!
    redirect_to organizations_path, notice: "Organizationを削除扱いにしました。物理削除はしていません。"
  end

  private

  def require_service_admin
    return if service_admin?

    deny_access("service_adminのみ操作できます")
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name)
  end
end
