import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-badge";

enum Kind {
  Default,
}

export default {
  title: "Public/canary-badge",
  parameters: { sourceLink: "components/canary-badge.stories.ts" },
  render: ({ kind, name }) => {
    if (kind === Kind.Default) {
      return html` <canary-badge name=${name}></canary-badge> `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind; name: string }>;

export const Default: StoryObj = {
  args: { kind: Kind.Default, name: "CLOSED" },
};
