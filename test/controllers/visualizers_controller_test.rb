require 'test_helper'

class VisualizersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @visualizer = visualizers(:one)
  end

  test "should get index" do
    get visualizers_url
    assert_response :success
  end

  test "should get new" do
    get new_visualizer_url
    assert_response :success
  end

  test "should create visualizer" do
    assert_difference('Visualizer.count') do
      post visualizers_url, params: { visualizer: { js_module_name: @visualizer.js_module_name, load_data: @visualizer.load_data, name: @visualizer.name } }
    end

    assert_redirected_to visualizer_url(Visualizer.last)
  end

  test "should show visualizer" do
    get visualizer_url(@visualizer)
    assert_response :success
  end

  test "should get edit" do
    get edit_visualizer_url(@visualizer)
    assert_response :success
  end

  test "should update visualizer" do
    patch visualizer_url(@visualizer), params: { visualizer: { js_module_name: @visualizer.js_module_name, load_data: @visualizer.load_data, name: @visualizer.name } }
    assert_redirected_to visualizer_url(@visualizer)
  end

  test "should destroy visualizer" do
    assert_difference('Visualizer.count', -1) do
      delete visualizer_url(@visualizer)
    end

    assert_redirected_to visualizers_url
  end
end
