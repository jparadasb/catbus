defmodule SmsBus.Tools.Parser do
  alias SmsBus.Models.{Route}

  @callback to_struct(html :: binary()) :: [Map.t()]
  def to_struct(_html) do
    [%Route{}]
  end
end
