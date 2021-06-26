defmodule SmsBus do
  @callback next_arrivals_by_route(stop_id :: binary()) :: Map.t()
  def next_arrivals_by_route(stop_id) do
  end
end
