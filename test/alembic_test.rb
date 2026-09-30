require "test_helper"

class AlembicTest < ActiveSupport::TestCase
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
