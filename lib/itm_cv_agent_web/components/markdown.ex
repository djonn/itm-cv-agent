defmodule ItMinds.CvAgentWeb.Markdown do
  use Phoenix.Component

  attr :text, :string, required: true

  def markdown(%{text: markdown_text} = assigns) do
    {:ok, html} = MDEx.to_html(markdown_text)
    assigns = assigns |> Map.put(:html, html)
    ~H"{Phoenix.HTML.raw(@html)}"
  end
end
