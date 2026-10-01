require "test_helper"

class AlembicTest < ActiveSupport::TestCase
  test "the owner method given to alembic reaches its easy_flow host" do
    Alembic.owner_method = :current_customer

    assert_equal :current_customer, EasyFlow.host_named(:alembic).owner_method
  ensure
    Alembic.owner_method = nil
  end

  test "setting the lead partial warns that the lead address replaces it" do
    assert_output(nil, /lead_partial no longer exists.*lead_address/) { Alembic.lead_partial = "diagnostics/lead" }
  end

  test "the admin layout given to alembic leaves another host's admin layout alone" do
    Alembic.admin_layout = "mailer"

    assert_equal "application", EasyFlow.host_named(:console).admin_layout
  ensure
    Alembic.admin_layout = nil
  end
end
