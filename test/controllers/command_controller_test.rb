require 'test_helper'

class CommandControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get command_show_url
    assert_response :success
  end

  test "should get create" do
    get command_create_url
    assert_response :success
  end

end
