defmodule ItMinds.CvAgentWeb.ErrorJSONTest do
  use ItMinds.CvAgentWeb.ConnCase, async: true

  test "renders 404" do
    assert ItMinds.CvAgentWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert ItMinds.CvAgentWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
