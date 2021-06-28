defmodule SmsBus.Tools.Scraper.Behaviour do
  @moduledoc false
  @callback get_next_arrivals_by(stop_id :: String.t()) :: tuple()
end
