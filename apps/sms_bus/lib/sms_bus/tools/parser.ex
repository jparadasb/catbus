defmodule SmsBus.Tools.Parser do
  alias SmsBus.Models.{Stop, Route, NextArrival}

  @callback to_struct(html :: binary() | {:ok, binary()} | {:error, binary()}) :: [Route.t()]

  @routes_error_selectors "div#servicio_error_solo_paradero, div#respuesta_error_solo_paradero"
  @routes_arrivals_selectors "div#siguiente_respuesta, div#proximo_solo_paradero"

  @first_case_selectors "#{@routes_arrivals_selectors}, #{@routes_error_selectors}"
  @second_case_selector "div#proximo_respuesta"
  @third_case_selector "div#respuesta_error"

  @stop_name_selector "div#nombre_paradero_respuesta"
  @stop_code_selector "div#numero_parada_respuesta>span:nth-child(2)"
  @stop_request_time "div#resultado_hora_respuesta>span.texto_h1"

  def to_struct({:ok, html}) do
    to_struct(html)
  end

  def to_struct({:error, _}) do
    []
  end

  def to_struct(html) do
    with {:ok, document} <- Floki.parse_document(html) do
      elements_first_case = find_node(document, @first_case_selectors)
      elements_second_case = find_node(document, @second_case_selector)
      elements_third_case = find_node(document, @third_case_selector)

      build_route_struct(document, elements_first_case, elements_second_case, elements_third_case)
    end
  end

  defp build_route_struct(document, first_case_nodes, _second_case, _third_case)
       when length(first_case_nodes) > 0 do
    %Stop{
      routes: get_routes(first_case_nodes),
      code: get_text(document, @stop_code_selector),
      name: get_text(document, @stop_name_selector),
      request_time: get_text(document, @stop_request_time)
    }
  end

  defp build_route_struct(document, _first_case, second_case_nodes, _third_case)
       when length(second_case_nodes) > 0 do
    %Stop{
      code: get_text(document, @stop_code_selector),
      name: get_text(document, @stop_name_selector),
      request_time: get_text(document, @stop_request_time),
      routes: get_routes(document, "div#proximo_respuesta")
    }
  end

  defp build_route_struct(document, _first_case, _second_case, third_case_nodes)
       when length(third_case_nodes) > 0 do
    %Stop{
      code: get_text(document, @stop_code_selector),
      name: get_text(document, @stop_name_selector),
      request_time: get_text(document, @stop_request_time),
      status_message: get_text(third_case_nodes, "div#respuesta_error"),
      routes: [
        %Route{
          service_number: get_text(document, "div#numero_parada_respuesta>span:nth-child(5)"),
          error_message: get_text(third_case_nodes)
        }
      ],
      status: :inactive
    }
  end

  defp build_route_struct(_document, _first_case, _second_case, _third_case) do
    %Stop{
      status_message: "Service Unavailable",
      status: :inactive
    }
  end

  defp get_routes(nodes) do
    find_node(nodes, @routes_arrivals_selectors)
    |> group_by_route_id()
    |> build_route()
    |> Enum.concat(
      find_node(nodes, @routes_error_selectors)
      |> get_and_match
    )
    |> Enum.sort_by(&{byte_size(&1.error_message), byte_size(&1.service_number)})
  end

  defp get_routes(node, selector = "div#proximo_respuesta") do
    [
      %Route{
        service_number: get_text(node, "div#numero_parada_respuesta>span:nth-child(5)"),
        next_arrivals:
          Floki.find(node, selector)
          |> Enum.map(fn n ->
            %NextArrival{
              arrival_time: get_text(n, "div#proximo_tiempo_respuesta"),
              distance: get_text(node, "div#proximo_distancia_respuesta"),
              number_plate: get_text(node, "div#proximo_bus_respuesta")
            }
          end)
      }
    ]
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

  defp get_and_match(_), do: []

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
