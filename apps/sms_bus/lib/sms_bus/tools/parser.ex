defmodule SmsBus.Tools.Parser do
  alias SmsBus.Models.{Route, NextArrival}

  @callback to_struct(html :: binary() | {:ok, binary()} | {:error, binary()}) :: [Route.t()]

  def to_struct({:ok, html}) do
    to_struct(html)
  end

  def to_struct({:error, _}) do
    []
  end

  def to_struct(html) do
    with {:ok, document} <- Floki.parse_document(html),
         arrivals_nodes <-
           find_node(document, "div#siguiente_respuesta, div#proximo_solo_paradero"),
         next_arrivals <- get_arrivals_from_nodes(arrivals_nodes),
         error_routes <- get_routes_with_errors_from_nodes(document) do
      next_arrivals
      |> Enum.concat(error_routes)
      |> Enum.sort_by(&{byte_size(&1.error_message), byte_size(&1.service_number)})
    end
  end

  defp get_routes_with_errors_from_nodes(node) do
    find_node(node, "div#servicio_error_solo_paradero, div#respuesta_error_solo_paradero")
    |> get_and_match
  end

  defp get_and_match([route_node | [message | tail]]) when length(tail) > 1 do
    [
      %Route{
        service_number: get_text(route_node),
        error_message: get_text(message)
      }
      | get_and_match(tail)
    ]
  end

  defp get_and_match([route_node | [message | _]]) do
    [
      %Route{
        service_number: get_text(route_node),
        error_message: get_text(message)
      }
    ]
  end

  defp get_arrivals_from_nodes(arrivals_nodes) do
    arrivals_nodes
    |> group_by_route_id()
    |> build_route()
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

  defp find_node(node, selector) do
    Floki.find(node, selector)
  end

  defp get_text(node, selector) do
    Floki.find(node, selector) |> get_text()
  end

  defp get_text(node) do
    node |> Floki.text() |> String.trim() |> String.replace(~r/\s+/, " ")
  end
end
