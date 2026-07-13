defmodule ItMinds.CvAgent.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
