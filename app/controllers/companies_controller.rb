class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update archive restore]
  before_action :authorize_company_edit, only: %i[edit update archive]
  before_action :authorize_company_restore, only: :restore

  def index
    @q = params[:q]
    @companies = scoped_companies.active.search(@q).order(:name)
  end

  def trash
    @companies = scoped_companies.archived.order(archived_at: :desc)
  end

  def show
    @duplicate_candidates = @company.duplicate_candidates
    @contacts = @company.contacts.active.order(:name)
  end

  def new
    @company = Company.new
  end

  def edit
    @duplicate_candidates = @company.duplicate_candidates
  end

  def create
    @company = Company.new(company_params)
    assign_current_organization(@company)
    assign_creator(@company)
    @duplicate_candidates = @company.duplicate_candidates

    if @company.save
      redirect_to @company, notice: "会社を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @company.assign_attributes(company_params)
    @duplicate_candidates = @company.duplicate_candidates

    if @company.save
      redirect_to @company, notice: "会社を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @company.archive!
    redirect_to companies_path, notice: "会社を非表示にしました"
  end

  def restore
    @company.restore!
    redirect_to @company, notice: "会社を表示に戻しました"
  end

  private

  def set_company
    @company = scoped_companies.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :website, :phone, :address, :description)
  end

  def authorize_company_edit
    ensure_editable!(@company)
  end

  def authorize_company_restore
    ensure_restorable!(@company)
  end
end
