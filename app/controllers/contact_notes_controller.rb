class ContactNotesController < ApplicationController
  before_action :set_contact
  before_action :set_contact_note, only: %i[destroy restore]
  before_action :authorize_note_edit, only: :destroy
  before_action :authorize_note_restore, only: :restore

  def create
    @contact_note = @contact.contact_notes.new(contact_note_params)
    @contact_note.organization = @contact.organization
    @contact_note.user = current_user

    if @contact_note.save
      redirect_to @contact, notice: "メモを追加しました"
    else
      redirect_to @contact, alert: @contact_note.errors.full_messages.to_sentence
    end
  end

  def destroy
    @contact_note.archive!
    redirect_to @contact, notice: "メモを非表示にしました"
  end

  def restore
    @contact_note.restore!
    redirect_to @contact, notice: "メモを表示に戻しました"
  end

  private

  def set_contact
    @contact = scoped_contacts.find(params[:contact_id])
  end

  def set_contact_note
    @contact_note = @contact.contact_notes.visible_to(current_user).find(params[:id])
  end

  def contact_note_params
    params.require(:contact_note).permit(:visibility, :body)
  end

  def authorize_note_edit
    ensure_editable!(@contact_note)
  end

  def authorize_note_restore
    ensure_restorable!(@contact_note)
  end
end
