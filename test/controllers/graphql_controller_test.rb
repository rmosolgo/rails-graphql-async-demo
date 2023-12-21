require "test_helper"

class GraphqlControllerTest < ActionDispatch::IntegrationTest
  test "it runs graphql" do
    post "/graphql", params: {
      query: "{ __typename }"
    }
    assert_equal({"data"=>{"__typename"=>"Query"}}, JSON.parse(response.body))
  end

  test "it does error handling" do
    post "/graphql", params: { query: "{ testError }" }

    assert_equal({"error" => true}, JSON.parse(response.body))

    post "/graphql", params: { query: "{ localCount(set: \"xyz\") }"}

    assert_equal 0, JSON.parse(response.body)["data"]["localCount"]
  end

  test "it can run more queries than are in the connection pool" do
    query_str = <<~GRAPHQL
      {
        c1: localCount(set: "shd")
        c2: localCount(set: "cfx")
        c3: localCount(set: "arb")
      }
    GRAPHQL

    10.times do
      post "/graphql", params: { query: query_str }
      res = JSON.parse(response.body)
      assert_equal 0, res["data"]["c1"]
      assert_equal 0, res["data"]["c2"]
      assert_equal 0, res["data"]["c3"]
    end
  end
end
