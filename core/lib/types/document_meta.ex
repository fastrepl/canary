defmodule Canary.Type.DocumentMeta do
  use Ash.Type.NewType,
    subtype_of: :union,
    constraints: [
      types: [
        webpage: [type: Canary.Sources.Webpage.DocumentMeta],
        openapi: [type: Canary.Sources.OpenAPI.DocumentMeta],
        github_issue: [type: Canary.Sources.GithubIssue.DocumentMeta],
        github_discussion: [type: Canary.Sources.GithubDiscussion.DocumentMeta],
        discord_thread: [type: Canary.Sources.DiscordThread.DocumentMeta]
      ]
    ]
end
