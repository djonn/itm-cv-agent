defmodule ItMinds.CvAgentWeb.PageController do
  use ItMinds.CvAgentWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
