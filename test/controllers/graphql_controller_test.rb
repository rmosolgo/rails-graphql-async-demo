require "test_helper"

class GraphqlControllerTest < ActionDispatch::IntegrationTest
  test "it runs graphql" do
    post "/graphql", params: {
      query: "{ __typename }"
    }
    assert_equal({"data"=>{"__typename"=>"Query"}}, JSON.parse(response.body))
  end
end
