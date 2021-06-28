defmodule SmsBus.Models.NextArrival do
  defstruct number_plate: "",
            arrival_time: "",
            distance: ""

  @type t() :: %__MODULE__{
          number_plate: String.t(),
          arrival_time: String.t(),
          distance: String.t()
        }
end
