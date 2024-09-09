defmodule Canary.Type.SourceConfig do
  use Ash.Type.NewType,
    subtype_of: :union,
    constraints: [
      types: [
        webpage: [type: Canary.Sources.Webpage.Config],
        github_issue: [type: Canary.Sources.GithubIssue.Config],
        github_discussion: [type: Canary.Sources.GithubDiscussion.Config],
        discord_thread: [type: Canary.Sources.DiscordThread.Config]
      ]
    ]
end
