defmodule SmsBus.Tools.Scraper do
  use Retry.Annotation

  @timeout 1000
  @exponential_backoff 100
  @expiry 30_000
  @entry_url "http://web.smsbus.cl/web"
  @service_url "#{@entry_url}/buscarAction.do?d=cargarServicios"
  @base_headers [
    {"Content-Type", "application/x-www-form-urlencoded"},
    {"Accept",
     'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'},
    {"User-Agent",
     'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36'}
  ]

  @callback get_next_arrivals_by(route_id :: binary()) :: {:ok, binary()} | {:error, binary()}
  def get_next_arrivals_by(route_id) do
    get_cookie()
    |> get_next_arrivals(route_id)
  end

  @retry with: exponential_backoff(@exponential_backoff) |> expiry(@expiry)
  defp get_cookie() do
    with {:ok, %HTTPoison.Response{status_code: 200, headers: headers}} <-
           HTTPoison.get(@service_url, @base_headers, timeout: @timeout),
         {{"Set-Cookie", cookie}, _headers} <- List.keytake(headers, "Set-Cookie", 0) do
      cookie
    else
      err -> err
    end
  end

  @retry with: exponential_backoff(@exponential_backoff) |> expiry(@expiry)
  defp get_next_arrivals(cookie, route_id) do
    req_body =
      %{
        "d" => "busquedaParadero",
        "destino_nombre" => "rrrrr",
        "servicio" => -1,
        "destino" => -1,
        "paradero" => -1,
        "ingresar_paradero" => route_id,
        "busqueda_rapida" => "PC616 C08"
      }
      |> URI.encode_query()

    case HTTPoison.post(
           @entry_url <> "/buscarAction.do",
           req_body,
           [
             {"Referer", "#{@entry_url}/buscarAction.do?d=cargarServicios"},
             {"Origin", 'Origin: http://web.smsbus.cl'},
             {"Cookie", cookie}
             | @base_headers
           ],
           timeout: @timeout
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      err -> err
    end
  end
end
