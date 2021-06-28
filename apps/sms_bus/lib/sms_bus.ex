defmodule SmsBus do
  @behaviour SmsBus.Behaviour
  @scraper Application.get_env(:sms_bus, :scraper)
  def next_arrivals_by_stop_id(stop_id) do
    IO.inspect(Mix.env())

    @scraper.get_next_arrivals_by(stop_id)
    |> IO.inspect()
    |> SmsBus.Tools.Parser.to_struct()
  end
end
