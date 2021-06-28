defmodule SmsBus.Tools.Parser do
  alias SmsBus.Models.{Route}

  @callback to_struct(html :: binary() | {:ok, binary()} | {:error, binary()}) :: [Map.t()]

  def to_struct({:ok, html}) do
    to_struct(html)
  end

  def to_struct(html) do
    with {:ok, document} <- Floki.parse_document(html) do
      Floki.find(document, "div#siguiente_respuesta")
    end
  end
end
