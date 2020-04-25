defmodule Response do
  @moduledoc """
  Map the response for api requests.
  """

  def response(data, error \\ false) do
    if error do
      %{
        error: data,
        result: nil
      }
    else
      %{
        error: nil,
        result: data
      }
    end
  end
end
