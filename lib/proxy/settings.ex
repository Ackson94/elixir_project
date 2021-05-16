defmodule Proxy.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false
  alias Proxy.Repo

  alias Proxy.Settings.Sms

  @doc """
  Returns the list of tbl_sms_config.

  ## Examples

      iex> list_tbl_sms_config()
      [%Sms{}, ...]

  """
  # def list_tbl_sms_config do
  #   Repo.all(Sms)
  # end

  def sms_configs do
    Repo.one(Sms)
  end

  @doc """
  Gets a single sms.

  Raises `Ecto.NoResultsError` if the Sms does not exist.

  ## Examples

      iex> get_sms!(123)
      %Sms{}

      iex> get_sms!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sms!(id), do: Repo.get!(Sms, id)

  @doc """
  Creates a sms.

  ## Examples

      iex> create_sms(%{field: value})
      {:ok, %Sms{}}

      iex> create_sms(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sms(attrs \\ %{}) do
    %Sms{}
    |> Sms.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sms.

  ## Examples

      iex> update_sms(sms, %{field: new_value})
      {:ok, %Sms{}}

      iex> update_sms(sms, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sms(%Sms{} = sms, attrs) do
    sms
    |> Sms.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sms.

  ## Examples

      iex> delete_sms(sms)
      {:ok, %Sms{}}

      iex> delete_sms(sms)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sms(%Sms{} = sms) do
    Repo.delete(sms)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sms changes.

  ## Examples

      iex> change_sms(sms)
      %Ecto.Changeset{source: %Sms{}}

  """
  def change_sms(%Sms{} = sms) do
    Sms.changeset(sms, %{})
  end

  alias Proxy.Settings.CoreBanking

  @doc """
  Returns the list of tbl_cb_config.

  ## Examples

      iex> list_tbl_cb_config()
      [%CoreBanking{}, ...]

  """
  # def list_tbl_cb_config do
  #   Repo.all(CoreBanking)
  # end

  def cb_configs do
    Repo.one(CoreBanking)
  end

  @doc """
  Gets a single core_banking.

  Raises `Ecto.NoResultsError` if the Core banking does not exist.

  ## Examples

      iex> get_core_banking!(123)
      %CoreBanking{}

      iex> get_core_banking!(456)
      ** (Ecto.NoResultsError)

  """
  def get_core_banking!(id), do: Repo.get!(CoreBanking, id)

  @doc """
  Creates a core_banking.

  ## Examples

      iex> create_core_banking(%{field: value})
      {:ok, %CoreBanking{}}

      iex> create_core_banking(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_core_banking(attrs \\ %{}) do
    %CoreBanking{}
    |> CoreBanking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a core_banking.

  ## Examples

      iex> update_core_banking(core_banking, %{field: new_value})
      {:ok, %CoreBanking{}}

      iex> update_core_banking(core_banking, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_core_banking(%CoreBanking{} = core_banking, attrs) do
    core_banking
    |> CoreBanking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a core_banking.

  ## Examples

      iex> delete_core_banking(core_banking)
      {:ok, %CoreBanking{}}

      iex> delete_core_banking(core_banking)
      {:error, %Ecto.Changeset{}}

  """
  def delete_core_banking(%CoreBanking{} = core_banking) do
    Repo.delete(core_banking)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking core_banking changes.

  ## Examples

      iex> change_core_banking(core_banking)
      %Ecto.Changeset{source: %CoreBanking{}}

  """
  def change_core_banking(%CoreBanking{} = core_banking) do
    CoreBanking.changeset(core_banking, %{})
  end
end
