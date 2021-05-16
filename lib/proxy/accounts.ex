defmodule Proxy.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Proxy.Repo

  alias Proxy.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## get the client by username
  # def get_by_username(username) do
  #   case Repo.get_by(User, username: String.downcase(username)) do
  #     nil -> {:error, "invalid username"}
  #     user -> {:ok, user}
  #   end
  # end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_user_by(nt_username) do
    Repo.all(
      from(
        u in User,
        where: fragment("lower(?) = lower(?)", u.nt_username, ^nt_username),
        limit: 1,
        select: u
      )
    )
  end

  def get_all_super_admins do
    Repo.all(
      from(
        u in User,
        where: u.user_role == 1,
        select: u
      )
    )
  end

  def get_all_users do
    Repo.all(
      from u in User,
        preload: [:user],
        select:
          map(
            u,
            [
              :id,
              :user_id,
              :inserted_at,
              :inserted_at,
              :updated_at,
              :first_name,
              :last_name,
              :username,
              :email,
              :status,
              :user_type,
              :user_role,
              user: [:first_name, :last_name]
            ]
          )
    )
  end

  alias Proxy.Accounts.Mno

  @doc """
  Returns the list of tbl_api_users.

  ## Examples

      iex> list_tbl_api_users()
      [%ApiUser{}, ...]

  """
  def list_tbl_mnos do
    Mno |> preload([:user]) |> Repo.all()
  end

  @doc """
  Gets a single api_user.

  Raises `Ecto.NoResultsError` if the Api user does not exist.

  ## Examples

      iex> get_api_user!(123)
      %ApiUser{}

      iex> get_api_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mno!(id), do: Repo.get!(Mno, id)


  ## get the client by username
  def get_mno_by_username(username) do
    case Repo.get_by(Mno, username: username) do
      nil -> {:error, "invalid username"}
      user -> {:ok, user}
    end
  end


  ## get the api_user by token
  def get_by_token(token) do
    case Repo.get_by(Mno, access_token: String.downcase(token)) do
      nil -> {:error, "invalid token"}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a api_user.

  ## Examples

      iex> create_api_user(%{field: value})
      {:ok, %ApiUser{}}

      iex> create_api_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mno(attrs \\ %{}) do
    %Mno{}
    |> Mno.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a api_user.

  ## Examples

      iex> update_api_user(api_user, %{field: new_value})
      {:ok, %ApiUser{}}

      iex> update_api_user(api_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_api_user(%Mno{} = mno, attrs) do
    mno
    |> Mno.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a api_user.

  ## Examples

      iex> delete_api_user(api_user)
      {:ok, %ApiUser{}}

      iex> delete_api_user(api_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mno(%Mno{} = mno) do
    Repo.delete(mno)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking api_user changes.

  ## Examples

      iex> change_api_user(api_user)
      %Ecto.Changeset{source: %ApiUser{}}

  """
  def change_mno(%Mno{} = mno) do
    Mno.changeset(mno, %{})
  end
end
