require "test_helper"

class KeystoneUi::React::MountHelperTest < ActionView::TestCase
  include KeystoneUi::React::MountHelper

  test "writes an element naming the React UI to mount" do
    render html: react_ui("test/greeting")

    assert_dom "[data-react-ui='test/greeting']"
  end

  test "gives the React UI its props as JSON" do
    render html: react_ui("test/greeting", { name: "Ada" })

    assert_dom "[data-props='{\"name\":\"Ada\"}']"
  end

  test "keeps the other attributes the page gives the element" do
    render html: react_ui("test/greeting", {}, class: "flex-1", data: { flow_canvas: true })

    assert_dom "div.flex-1[data-flow-canvas][data-react-ui='test/greeting']"
  end
end
