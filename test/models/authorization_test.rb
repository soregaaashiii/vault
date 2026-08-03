require "test_helper"

class AuthorizationTest < ActiveSupport::TestCase
  setup do
    @org = Organization.create!(name: "Org A")
    @other_org = Organization.create!(name: "Org B")
    @service_admin = User.create!(name: "Service", email: "service-auth@example.com", role: "service_admin", password: "password")
    @org_admin = User.create!(organization: @org, name: "Admin", email: "admin-auth@example.com", role: "org_admin", password: "password")
    @member = User.create!(organization: @org, name: "Member", email: "member-auth@example.com", role: "member", password: "password")
    @other_member = User.create!(organization: @other_org, name: "Other", email: "other-auth@example.com", role: "member", password: "password")
    @company = Company.create!(organization: @org, created_by: @member, name: "Own Company")
    @other_company = Company.create!(organization: @org, created_by: @org_admin, name: "Admin Company")
  end

  test "service_admin can see all organizations" do
    assert_includes Organization.accessible_to(@service_admin), @org
    assert_includes Organization.accessible_to(@service_admin), @other_org
  end

  test "org users are scoped to their organization" do
    assert_equal [ @org.id ], Organization.accessible_to(@member).pluck(:id)
    assert_not_includes Company.accessible_to(@member), Company.create!(organization: @other_org, created_by: @other_member, name: "Other Company")
  end

  test "member can edit only own company and cannot restore hidden data" do
    assert @company.editable_by?(@member)
    assert_not @other_company.editable_by?(@member)
    assert_not @company.restorable_by?(@member)
  end

  test "org_admin can manage members but not service admins" do
    assert @member.manageable_by?(@org_admin)
    assert_not @service_admin.manageable_by?(@org_admin)
  end
end
