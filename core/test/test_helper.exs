Mox.defmock(Canary.Sessions.Responder.Mock, for: Canary.Sessions.Responder)
Application.put_env(:canary, :session_responder, Canary.Sessions.Responder.Mock)

Mox.defmock(Canary.AI.Mock, for: Canary.AI)
Application.put_env(:canary, :ai, Canary.AI.Mock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Canary.Repo, :manual)
