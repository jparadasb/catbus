defmodule SmsBus.Tools.Parser do
  @callback to_struct(html :: binary()) :: Map.t()

  def to_struct(html) do
  end
end
