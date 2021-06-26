defmodule SmsBus.Tools.ParserTest do
  alias SmsBus.Models.{NextArrival, Route, OutInformation}
  use ExUnit.Case
  import Mox
  doctest SmsBus

  Mox.defmock(SmsBus.Tools.MockScraper, for: SmsBus.Tools.Scraper)

  test "parser to struct response" do
    SmsBus.Tools.MockScraper
    |> expect(:get_next_arrivals_by, fn {_} ->
      {:ok, File.read!("../fixtures/response_full.html")}
    end)

    assert SmsBus.Tools.Scraper.get_next_arrivals_by("PC616") |> SmsBus.Tools.Parser.to_struct() ==
             [
               %Route{
                 service_number: "406C",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "PFTW-19",
                     arrival_time: "Entre 07 Y 09 min.",
                     distance: "2669 mts."
                   },
                   %NextArrival{
                     number_plate: "LXWP-87",
                     arrival_time: "Entre 12 Y 16 min.",
                     distance: "4793 mts."
                   }
                 ]
               },
               %Route{
                 service_number: "409",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "PFVG-73",
                     arrival_time: "Llegando.",
                     distance: "65 mts."
                   },
                   %NextArrival{
                     number_plate: "PGBY-62",
                     arrival_time: "Entre 04 Y 06 min.",
                     distance: "2118 mts."
                   }
                 ]
               },
               %Route{
                 service_number: "502",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "FLXG-34",
                     arrival_time: "Menos de 3 min.",
                     distance: "573 mts."
                   }
                 ]
               },
               %Route{
                 service_number: "C01",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "FZJL-69",
                     arrival_time: "Menos de 4 min.",
                     distance: "1235 mts."
                   },
                   %NextArrival{
                     number_plate: "CPBF-99",
                     arrival_time: "Mas de 25 min.",
                     distance: "6563 mts."
                   }
                 ]
               },
               %Route{
                 service_number: "C01C",
                 next_arrivals: [%OutInformation{}]
               },
               %Route{
                 service_number: "C05",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "CJRY-50",
                     arrival_time: "Llegando.",
                     distance: "309 mts."
                   }
                 ]
               },
               %Route{
                 service_number: "C08",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "CJRR-11",
                     arrival_time: "Menos de 3 min.",
                     distance: "333 mts."
                   },
                   %NextArrival{
                     number_plate: "CJRY-18",
                     arrival_time: "Entre 09 Y 13 min.",
                     distance: "4215 mts."
                   }
                 ]
               },
               %Route{
                 service_number: "C12",
                 next_arrivals: [
                   %OutInformation{message: "Frecuencia estimada es 1 bus cada 15 min."}
                 ]
               },
               %Route{
                 service_number: "C16",
                 next_arrivals: [
                   %NextArrival{
                     number_plate: "CJRK-44",
                     arrival_time: "Entre 10 Y 14 min.",
                     distance: "3497 mts."
                   }
                 ]
               }
             ]
  end
end
