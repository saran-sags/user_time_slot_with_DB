require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get slot" do
    get api_v1_users_slot_url
    assert_response :success
  end
end
