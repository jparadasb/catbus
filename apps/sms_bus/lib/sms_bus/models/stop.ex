defmodule SmsBus.Models.Stop do
  alias SmsBus.Models.{Route}

  defstruct name: "",
            routes: [],
            code: "",
            status: :active,
            status_message: "",
            request_time: "",
            timestamp: :os.system_time(:millisecond)

  @type t() :: %__MODULE__{
          name: String.t(),
          code: String.t(),
          routes: [Route.t()],
          status: :active | :inactive,
          status_message: String.t(),
          request_time: String.t(),
          timestamp: Integer.t()
        }
end
