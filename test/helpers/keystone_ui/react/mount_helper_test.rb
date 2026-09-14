require "test_helper"

class KeystoneUi::React::MountHelperTest < ActionView::TestCase
  include KeystoneUi::React::MountHelper

  test "writes an element naming the React UI to mount" do
    render html: react_ui("test/greeting")

    assert_dom "[data-react-ui='test/greeting']"
  end

  test "gives the React UI its props as JSON" do
    render html: react_ui("test/greeting", name: "Ada")

    assert_dom "[data-props='{\"name\":\"Ada\"}']"
  end
end
