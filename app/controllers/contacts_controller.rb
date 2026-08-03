class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show edit update archive restore]
  before_action :set_company_options, only: %i[new edit create update]
  before_action :authorize_contact_edit, only: %i[edit update archive]
  before_action :authorize_contact_restore, only: :restore

  def index
    redirect_to root_path
  end

  def trash
    @contacts = scoped_contacts.archived.includes(:company).order(archived_at: :desc)
  end

  def scan
  end

  def create_from_card
    upload = params.dig(:business_card_scan, :image)
    if upload.blank?
      redirect_to scan_contacts_path, alert: "名刺画像を選択してください"
      return
    end

    text = params.dig(:business_card_scan, :text).presence || BusinessCardOcr.extract_text(upload)
    parsed = BusinessCardParser.parse(text)
    company = find_or_create_company_from_card(parsed[:company_name])
    @contact = scoped_contacts.active.find_or_initialize_by(email: parsed[:email].presence) if parsed[:email].present?
    @contact ||= Contact.new
    if @contact.persisted? && !@contact.editable_by?(current_user)
      deny_access("この名刺情報を編集する権限がありません")
      return
    end
    @contact.assign_attributes(
      company: company || @contact.company,
      name: parsed[:name],
      email: parsed[:email],
      phone: parsed[:phone],
      position: parsed[:position],
      memo: card_scan_memo(parsed)
    )
    assign_current_organization(@contact)
    assign_creator(@contact)
    @contact.save!

    business_card = @contact.business_cards.create!(
      organization: @contact.organization,
      created_by: current_user,
      label: "自動読取 #{Time.zone.today}",
      image: upload
    )

    redirect_to @contact, notice: "名刺を登録しました。会社名を読み取れた場合は会社検索にも表示されます。"
  rescue => error
    redirect_to scan_contacts_path, alert: "#{error.message}。OCRが使えない場合は、画像と一緒に「読み取りテキスト」を入力してください。"
  end

  def show
    @duplicate_candidates = @contact.duplicate_candidates
    @business_card = BusinessCard.new
    @contact_note = ContactNote.new(visibility: "shared")
    cards_scope = @contact.business_cards.order(created_at: :desc)
    @business_cards = (service_admin? || org_admin?) ? cards_scope : cards_scope.active
    @contact_notes = @contact.contact_notes.active.visible_to(current_user).includes(:user).order(created_at: :desc)
    @archived_notes = if service_admin? || org_admin?
      @contact.contact_notes.archived.visible_to(current_user).includes(:user).order(archived_at: :desc)
    else
      ContactNote.none
    end
  end

  def new
    @contact = Contact.new(company_id: params[:company_id])
  end

  def edit
    @duplicate_candidates = @contact.duplicate_candidates
  end

  def create
    @contact = Contact.new(contact_params)
    assign_current_organization(@contact)
    assign_creator(@contact)
    @duplicate_candidates = @contact.duplicate_candidates

    if @contact.save
      redirect_to @contact, notice: "担当者を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @contact.assign_attributes(contact_params)
    @duplicate_candidates = @contact.duplicate_candidates

    if @contact.save
      redirect_to @contact, notice: "担当者を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @contact.archive!
    redirect_to root_path, notice: "担当者を非表示にしました"
  end

  def restore
    @contact.restore!
    redirect_to @contact, notice: "担当者を表示に戻しました"
  end

  private

  def set_contact
    @contact = scoped_contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:company_id, :name, :email, :phone, :position, :memo)
  end

  def set_company_options
    @company_options = scoped_companies.active.order(:name)
  end

  def find_or_create_company_from_card(company_name)
    return nil if company_name.blank?

    scope = scoped_companies.active
    existing = scope.where("lower(name) = ?", company_name.downcase).first
    return existing if existing

    organization = current_organization || Organization.first
    company = organization.companies.create!(name: company_name, created_by: current_user)
    company
  end

  def card_scan_memo(parsed)
    [
      "名刺画像から自動登録しました。",
      "",
      "OCR全文:",
      parsed[:raw_text]
    ].join("\n")
  end

  def authorize_contact_edit
    ensure_editable!(@contact)
  end

  def authorize_contact_restore
    ensure_restorable!(@contact)
  end
end
