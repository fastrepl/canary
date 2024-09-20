import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import type { SearchResult } from "../types";

import "./canary-search-match";

enum Kind {
  Webpage,
  GithubIssue,
  GithubDiscussion,
}

export default {
  title: "Public/canary-search-match",
  parameters: { sourceLink: "components/canary-search-match.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Webpage) {
      const match: SearchResult = {
        type: "webpage",
        meta: {},
        url: "https://example.com",
        title: "Title",
        excerpt: "This is a mock excerpt for webpage.",
        sub_results: [
          {
            title: "Page sub title 1",
            url: "https://example.com/a#sub-1",
            excerpt: "this is <mark>a match</mark>.",
          },
        ],
      };

      return html`
        <div style="width: 600px;">
          <canary-search-match .match=${match}></canary-search-match>
        </div>
      `;
    }

    if (kind === Kind.GithubIssue) {
      const match: SearchResult = {
        type: "github_issue",
        meta: {
          closed: false,
        },
        url: "https://example.com",
        title: "Title",
        excerpt: "This is a mock excerpt for webpage.",
        sub_results: [
          {
            title: "Page sub title 1",
            url: "https://example.com/a#sub-1",
            excerpt: "this is <mark>a match</mark>.",
          },
        ],
      };

      return html`
        <div style="width: 600px;">
          <canary-search-match .match=${match}></canary-search-match>
        </div>
      `;
    }

    if (kind === Kind.GithubDiscussion) {
      const match: SearchResult = {
        type: "github_discussion",
        meta: {
          closed: false,
          answered: false,
        },
        url: "https://example.com",
        title: "Title",
        excerpt: "This is a mock excerpt for webpage.",
        sub_results: [
          {
            title: "Page sub title 1",
            url: "https://example.com/a#sub-1",
            excerpt: "this is <mark>a match</mark>.",
          },
        ],
      };

      return html`
        <div style="width: 600px;">
          <canary-search-match .match=${match}></canary-search-match>
        </div>
      `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Webpage: StoryObj = {
  args: { kind: Kind.Webpage },
};
export const GithubIssue: StoryObj = {
  args: { kind: Kind.GithubIssue },
};
export const GithubDiscussion: StoryObj = {
  args: { kind: Kind.GithubDiscussion },
};
