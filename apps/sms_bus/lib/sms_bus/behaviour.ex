defmodule SmsBus.Behaviour do
  @callback next_arrivals_by_stop_id(stop_id :: String.t()) :: Map.t()
end
