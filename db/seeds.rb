org = Organization.find_or_create_by!(name: "Demo Organization")

admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  organization: org,
  name: "Org Admin",
  role: "org_admin",
  password: "password",
  password_confirmation: "password"
)
admin.save!

member = User.find_or_initialize_by(email: "member@example.com")
member.assign_attributes(
  organization: org,
  name: "Member",
  role: "member",
  password: "password",
  password_confirmation: "password"
)
member.save!

service_admin = User.find_or_initialize_by(email: "service@example.com")
service_admin.assign_attributes(
  name: "Service Admin",
  role: "service_admin",
  password: "password",
  password_confirmation: "password"
)
service_admin.save!

company = org.companies.find_or_create_by!(name: "Vault Sample Inc.") do |record|
  record.created_by = admin
  record.website = "https://example.com"
  record.phone = "03-0000-0000"
  record.address = "東京都千代田区"
  record.description = "VAULT MVPのサンプル会社です。"
end

contact = org.contacts.find_or_create_by!(name: "山田 太郎", company:) do |record|
  record.created_by = admin
  record.email = "taro@example.com"
  record.phone = "090-0000-0000"
  record.position = "営業部長"
end

contact.contact_notes.find_or_create_by!(user: admin, visibility: "shared", body: "初回訪問済み。次回は導入時期を確認する。", organization: org)
contact.contact_notes.find_or_create_by!(user: admin, visibility: "personal", body: "趣味はランニング。", organization: org)
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
