defmodule SmsBus.Tools.Parser do
  alias SmsBus.Models.{Route, NextArrival}

  @callback to_struct(html :: binary() | {:ok, binary()} | {:error, binary()}) :: [Map.t()]

  def to_struct({:ok, html}) do
    to_struct(html)
  end

  def to_struct(html) do
    with {:ok, document} <- Floki.parse_document(html),
         next_arrivals <-
           Floki.find(document, "div#siguiente_respuesta, div#proximo_solo_paradero") do
      next_arrivals
      |> group_by_route_id()
      |> build_route()
    end
  end

  defp build_route(arrivals_grouped) do
    arrivals_grouped
    |> Enum.map(fn {service_number, node} ->
      %Route{
        next_arrivals: build_next_arrivals(node),
        service_number: service_number
      }
    end)
  end

  defp build_next_arrivals(node) do
    node
    |> Enum.map(fn node ->
      %NextArrival{
        arrival_time: get_text(node, "div#tiempo_respuesta_solo_paradero"),
        distance: get_text(node, "div#distancia_respuesta_solo_paradero"),
        number_plate: get_text(node, "div#bus_respuesta_solo_paradero")
      }
    end)
  end

  defp group_by_route_id(next_arrivals) do
    Enum.group_by(next_arrivals, fn arrival ->
      Floki.find(arrival, "div#servicio_respuesta_solo_paradero")
      |> Floki.text()
    end)
  end

  defp get_text(node, selector) do
    Floki.find(node, selector) |> Floki.text() |> String.trim()
  end
end
