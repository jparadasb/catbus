defmodule SmsBus do
  @callback next_arrivals_by_route(route_id :: binary()) :: Map.t()
  def next_arrivals_by_route(route_id) do
  end
end
