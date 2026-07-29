defmodule DateExtension do
  @months ~w"Januar Februar Marts April Maj Juni Juli August Septemper Oktober November December"

  def to_string(%Date{} = date) do
    {year, month, day} = Date.to_erl(date)
    month = Enum.at(@months, month - 1)
    "#{day}. #{month} #{year}"
  end
end
