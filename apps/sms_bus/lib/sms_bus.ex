defmodule SmsBus do
  @callback next_arrivals_by_stop_id(stop_id :: binary()) :: Map.t()
  def next_arrivals_by_stop_id(stop_id) do
  end
end
