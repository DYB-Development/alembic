require "application_system_test_case"

module Alembic
  class CategoryBuilderTest < ApplicationSystemTestCase
    test "a builder writes a category with a true/false and a multiple choice question" do
      visit alembic.manage_categories_path
      click_on "New category"
      fill_in "category[name]", with: "Rivers"
      click_on "Create"

      click_on "Add a true/false question"
      fill_in "question[text]", with: "The Nile flows north."
      find("label", text: "False").click
      click_on "Create"

      click_on "Add a multiple choice question"
      fill_in "question[text]", with: "Which river is longest?"
      all("input[name='question[labels][]']")[0].fill_in(with: "Amazon")
      all("input[name='question[labels][]']")[1].fill_in(with: "Nile")
      all("input[name='question[right]']")[1].click
      click_on "Create"

      assert_selector "li", text: /The Nile flows north\.\s+Right answer: False/
      assert_selector "li", text: /Which river is longest\?\s+Right answer: Nile/
    end
  end
end
