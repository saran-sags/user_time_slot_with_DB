require "test_helper"

class Api::V1::TimeControllerTest < ActionDispatch::IntegrationTest
  test "should get slot" do
    get api_v1_time_slot_url
    assert_response :success
  end
end
