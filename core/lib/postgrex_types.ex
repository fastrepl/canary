Postgrex.Types.define(
  Canary.PostgrexTypes,
  [AshPostgres.Extensions.Vector] ++ Ecto.Adapters.Postgres.extensions(),
  []
)
