defmodule CurrencyService do
  @moduledoc """
  Currency service, handle the currency logic operations.
  """

  @base_url "https://api.exchangeratesapi.io/latest"

  @type conversion_result ::
          {:error, <<_::64, _::_*8>>}
          | {:ok, %{amount_converted: float, amount_to_convert: number, from: binary, to: binary}}

  use Tesla

  plug(Tesla.Middleware.BaseUrl, @base_url)
  plug(Tesla.Middleware.JSON)

  @doc """
  Return the currency conversion.

  ## Parameters

    - from: String that represents the 3 digits currency to convert from.
    - to: String that represents the 3 digits currency to convert to.
    - amount: Number that represents the amount to be converted.

  ## Examples

      iex> Conversion.handle_conversion("usd", "brl", 1)

      iex> Conversion.handle_conversion("unknowncurrency", "brl", 1)
      {:error, "unknowncurrency isn't supported."}

  """
  @spec handle_conversion(binary, binary, number) :: conversion_result
  def handle_conversion(from, to, amount) do
    amount_parsed = if is_binary(amount), do: Float.parse(amount) |> elem(0), else: amount

    cond do
      amount_parsed <= 0 ->
        {:error, "Amount must be bigger than 0"}

      !is_valid_currency?(from) ->
        {:error, "#{from} isn't supported."}

      !is_valid_currency?(to) ->
        {:error, "#{to} isn't supported."}

      true ->
        {:ok, rates} = get_latest_rates(from)

        converted = convert(rates["rates"][String.upcase(to)], amount_parsed)

        {:ok,
         %{
           from: from,
           to: to,
           amount_to_convert: amount,
           amount_converted: converted
         }}
    end
  end

  defp convert(rate, amount) do
    (rate * amount)
    |> Float.ceil(2)
  end

  @spec is_valid_currency?(String.t()) :: boolean
  def is_valid_currency?(currency) when byte_size(currency) > 0 do
    currencies = get_valid_currencies()

    Enum.member?(currencies, String.upcase(currency))
  end

  @spec get_latest_rates :: {:error, <<_::272>>} | {:ok, any}
  def get_latest_rates do
    {:ok, response} = request_rates("/")

    if response.status == 200 do
      {:ok, response.body}
    else
      {:error, "Fail get latest rates from server!"}
    end
  end

  @spec get_latest_rates(binary) :: {:error, <<_::272>>} | {:ok, any}
  def get_latest_rates(base) when byte_size(base) > 0 do
    {:ok, response} = request_rates("?base=#{String.upcase(base)}")

    if response.status == 200 do
      {:ok, response.body}
    else
      {:error, "Fail get latest rates from server!"}
    end
  end

  @spec get_valid_currencies :: [...]
  def get_valid_currencies do
    {:ok, rates} = get_latest_rates()

    Map.keys(rates["rates"])
  end

  defp request_rates(extend) do
    get(@base_url <> extend)
  end
end
