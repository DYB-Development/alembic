require "test_helper"

class KeystoneUi::React::MountHelperTest < ActionView::TestCase
  include KeystoneUi::React::MountHelper

  test "writes an element naming the React UI to mount" do
    render html: react_ui("test/greeting")

    assert_dom "[data-react-ui='test/greeting']"
  end
end
