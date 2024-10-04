defmodule Canary.Type.DocumentChunk do
  use Ash.Type.NewType,
    subtype_of: :union,
    constraints: [
      types: [
        webpage: [type: Canary.Sources.Webpage.Chunk],
        openapi: [type: Canary.Sources.OpenAPI.Chunk],
        github_issue: [type: Canary.Sources.GithubIssue.Chunk],
        github_discussion: [type: Canary.Sources.GithubDiscussion.Chunk],
        discord_thread: [type: Canary.Sources.DiscordThread.Chunk]
      ]
    ]
end
