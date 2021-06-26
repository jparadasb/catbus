defmodule SmsBus.Models.Routes do
  defstruct service_number: "",
            next_arrivals: [],
            name: "",
            request_time: :os.system_time(:milli_seconds)
end
