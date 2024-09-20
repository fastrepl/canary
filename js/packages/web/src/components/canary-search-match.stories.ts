import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

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
      return html`
        <div style="width: 600px;">
          <canary-search-match></canary-search-match>
        </div>
      `;
    }

    if (kind === Kind.GithubIssue) {
      return html`
        <div style="width: 600px;">
          <canary-search-match></canary-search-match>
        </div>
      `;
    }

    if (kind === Kind.GithubDiscussion) {
      return html`
        <div style="width: 600px;">
          <canary-search-match></canary-search-match>
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
