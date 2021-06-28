defmodule SmsBus.Models.Route do
  alias SmsBus.Models.{NextArrival}

  defstruct service_number: "",
            next_arrivals: [],
            error_message: ""

  @type t() :: %__MODULE__{
          service_number: String.t(),
          next_arrivals: [NextArrival.t()],
          error_message: String.t()
        }
end
