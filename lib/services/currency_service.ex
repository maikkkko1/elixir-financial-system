defmodule CurrencyService do
  @moduledoc """
  Currency service, handle currency logic operations.
  """

  @base_url "https://api.exchangeratesapi.io/latest"

  @type conversion_result ::
          {:error, String.t()}
          | {:ok,
             %{
               amount_converted: float,
               amount_to_convert: number,
               from: String.t(),
               to: String.t()
             }}

  use Tesla

  plug(Tesla.Middleware.BaseUrl, @base_url)
  plug(Tesla.Middleware.JSON)

  @doc """
  Handle the currency conversion.

  ## Parameters

    - from: String that represents the 3 digits currency to convert from.
    - to: String that represents the 3 digits currency to convert to.
    - amount: Number that represents the amount to be converted.

  ## Examples

      iex> CurrencyService.handle_conversion("usd", "brl", 1)

      iex> CurrencyService.handle_conversion("unknowncurrency", "brl", 1)
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

  @doc """
  Return if is a valid currency.

  ## Parameters

    - currency: String that represents the 3 digits currency to validate.

  """
  @spec is_valid_currency?(String.t()) :: boolean
  def is_valid_currency?(currency) do
    if byte_size(currency) <= 0, do: false

    currencies = get_valid_currencies()

    Enum.member?(currencies, String.upcase(currency))
  end

  @doc """
  Return the all the latest currencies rates.

  """
  @spec get_latest_rates :: {:error, String.t()} | {:ok, any}
  def get_latest_rates do
    {:ok, response} = request_rates("/")

    if response.status == 200 do
      {:ok, response.body}
    else
      {:error, "Fail get latest rates from server!"}
    end
  end

  @doc """
  Return the all the latest currencies rates based on some currency.

  ## Parameters

    - base: String that represents the 3 digits currency to be used as base.

  """
  @spec get_latest_rates(binary) :: {:error, String.t()} | {:ok, any}
  def get_latest_rates(base) when byte_size(base) > 0 do
    {:ok, response} = request_rates("?base=#{String.upcase(base)}")

    if response.status == 200 do
      {:ok, response.body}
    else
      {:error, "Fail get latest rates from server!"}
    end
  end

  @doc """
  Return a list with all valid currencies.

  """
  @spec get_valid_currencies :: [...]
  def get_valid_currencies do
    {:ok, rates} = get_latest_rates("USD")

    Map.keys(rates["rates"])
  end

  defp convert(rate, amount) do
    (rate * amount)
    |> Float.ceil(2)
  end

  defp request_rates(extend) do
    get(@base_url <> extend)
  end
end
