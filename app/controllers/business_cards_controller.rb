class BusinessCardsController < ApplicationController
  before_action :set_contact, except: :index
  before_action :set_business_card, only: %i[destroy restore]
  before_action :authorize_contact_for_card, only: :create
  before_action :authorize_card_edit, only: :destroy
  before_action :authorize_card_restore, only: :restore

  def index
    @q = params[:q]
    @tab = params[:tab] == "companies" ? "companies" : "cards"

    if @tab == "companies"
      @companies = scoped_companies.active.search(@q).order(:name)
    else
      @contacts = scoped_contacts
        .active
        .includes(:company, business_cards: { image_attachment: :blob })
        .search(@q)
        .order(:name)
    end
  end

  def create
    @business_card = @contact.business_cards.new(business_card_params)
    @business_card.organization = @contact.organization
    assign_creator(@business_card)

    if @business_card.save
      redirect_to @contact, notice: "名刺画像をアップロードしました"
    else
      redirect_to @contact, alert: @business_card.errors.full_messages.to_sentence
    end
  end

  def destroy
    @business_card.archive!
    redirect_to @contact, notice: "名刺を非表示にしました"
  end

  def restore
    @business_card.restore!
    redirect_to @contact, notice: "名刺を表示に戻しました"
  end

  private

  def set_contact
    @contact = scoped_contacts.find(params[:contact_id])
  end

  def set_business_card
    @business_card = @contact.business_cards.find(params[:id])
  end

  def business_card_params
    params.require(:business_card).permit(:label, :image)
  end

  def authorize_contact_for_card
    ensure_editable!(@contact)
  end

  def authorize_card_edit
    ensure_editable!(@business_card)
  end

  def authorize_card_restore
    ensure_restorable!(@business_card)
  end
end
