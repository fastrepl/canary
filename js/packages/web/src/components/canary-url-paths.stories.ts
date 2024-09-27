import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-url-paths";

enum Kind {
  FullURL,
  OnlyPath,
}

export default {
  title: "Public/canary-url-paths",
  parameters: { sourceLink: "components/canary-url-paths.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.FullURL) {
      return html`
        <canary-url-paths url="https://example.com/docs/a/b"></canary-url-paths>
      `;
    }

    if (kind === Kind.OnlyPath) {
      return html` <canary-url-paths url="/docs/a/b"></canary-url-paths> `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const FullURL: StoryObj = {
  args: { kind: Kind.FullURL },
};

export const OnlyPath: StoryObj = {
  args: { kind: Kind.OnlyPath },
};
