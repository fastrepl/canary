Mox.defmock(Canary.Interactions.Responder.Mock, for: Canary.Interactions.Responder)
Application.put_env(:canary, :responder, Canary.Interactions.Responder.Mock)

Mox.defmock(Canary.AI.Mock, for: Canary.AI)
Application.put_env(:canary, :ai, Canary.AI.Mock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Canary.Repo, :manual)
