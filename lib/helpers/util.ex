defmodule Util do
  @moduledoc """
  Util functions.
  """

  @spec is_valid_string?(String.t()) :: boolean
  def is_valid_string?(string) do
    is_binary(string) && string != nil && byte_size(string) > 0
  end
end
