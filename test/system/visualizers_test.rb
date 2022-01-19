require "application_system_test_case"

class VisualizersTest < ApplicationSystemTestCase
  setup do
    @visualizer = visualizers(:one)
  end

  test "visiting the index" do
    visit visualizers_url
    assert_selector "h1", text: "Visualizers"
  end

  test "creating a Visualizer" do
    visit visualizers_url
    click_on "New Visualizer"

    fill_in "Js module name", with: @visualizer.js_module_name
    fill_in "Load data", with: @visualizer.load_data
    fill_in "Name", with: @visualizer.name
    click_on "Create Visualizer"

    assert_text "Visualizer was successfully created"
    click_on "Back"
  end

  test "updating a Visualizer" do
    visit visualizers_url
    click_on "Edit", match: :first

    fill_in "Js module name", with: @visualizer.js_module_name
    fill_in "Load data", with: @visualizer.load_data
    fill_in "Name", with: @visualizer.name
    click_on "Update Visualizer"

    assert_text "Visualizer was successfully updated"
    click_on "Back"
  end

  test "destroying a Visualizer" do
    visit visualizers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Visualizer was successfully destroyed"
  end
end
