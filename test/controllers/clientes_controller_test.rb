require "test_helper"

class ClientesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get clientes_index_url
    assert_response :success
  end
end
