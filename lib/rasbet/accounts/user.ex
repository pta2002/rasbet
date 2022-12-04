defmodule Rasbet.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rasbet.Game.Bets.Bet

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true, redact: true)
    field(:password_confirmation, :string, virtual: true, redact: true)
    field(:hashed_password, :string, redact: true)
    field(:confirmed_at, :naive_datetime)
    field(:balance, Money.Ecto.Amount.Type)
    field(:is_admin, :boolean, default: false)

    field(:phone, :string)

    field(:country_code, :string, virtual: true)
    field(:local_phone, :string, virtual: true)

    field(:taxid, :string)
    field(:address1, :string)
    field(:address2, :string)
    # two letter country code
    field(:country, :string)
    field(:city, :string)
    field(:zipcode, :string)

    field(:birthdate, :date)
    field(:profession, :string)
    field(:id_number, :string)

    has_many(:bets, Bet)

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :password_confirmation,
      :country_code,
      :local_phone,
      :taxid,
      :address1,
      :address2,
      :country,
      :city,
      :zipcode,
      :birthdate,
      :profession,
      :id_number
    ])
    |> validate_email()
    |> validate_phone()
    |> validate_address()
    |> validate_age()
    |> validate_required([:phone, :taxid, :name, :profession, :id_number])
    |> then(fn changeset ->
      if not Keyword.get(opts, :is_edit, false) do
        validate_password(changeset, opts)
      else
        changeset
      end
    end)
  end

  def validate_age(changeset) do
    changeset
    |> validate_required([:birthdate])
    |> validate_over_18()
  end

  def validate_over_18(changeset) do
    date? = fetch_field!(changeset, :birthdate)

    if date? do
      %Date{year: y_birth, month: m_birth, day: d_birth} = date?
      {{y_curr, m_curr, d_curr}, _time} = :calendar.now_to_datetime(:erlang.now())

      age =
        cond do
          m_curr > m_birth or
              (m_birth == m_curr and d_curr >= d_birth) ->
            y_curr - y_birth

          true ->
            y_curr - y_birth - 1
        end

      if(age < 18) do
        add_error(
          changeset,
          :birthdate,
          RasbetWeb.ErrorHelpers.translate_error({
            "You need to be over 18 to create an account",
            []
          })
        )
      else
        changeset
      end
    else
      changeset
    end
  end

  def validate_phone(changeset) do
    # TODO: If :phone is set, ignore country code and local phone
    changeset
    |> validate_required([:country_code, :local_phone])
    |> put_change(
      :phone,
      "+#{get_change(changeset, :country_code)}#{get_change(changeset, :local_phone)}"
    )
    |> validate_required([:phone])
    |> validate_format(:phone, ~r/^\+\d+$/, message: "invalid phone number")
    |> unsafe_validate_unique(:phone, Rasbet.Repo)
    |> unique_constraint(:phone)
  end

  def validate_address(changeset) do
    changeset
    |> validate_required([:address1, :country, :city, :zipcode])
    |> validate_change(:country, fn :country, country ->
      if not Countries.exists?(:alpha2, country) do
        [country: "country does not exist"]
      else
        []
      end
    end)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Rasbet.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 12, max: 72)
    |> validate_confirmation(:password, message: "passwords don't match")
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Rasbet.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
