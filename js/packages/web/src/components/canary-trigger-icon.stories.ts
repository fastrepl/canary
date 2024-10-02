import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger-icon";

enum Kind {
  Icon,
}

export default {
  title: "public-components/canary-trigger-icon",
  component: "canary-trigger-icon",
  parameters: { sourceLink: "components/canary-trigger.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Icon) {
      return html` <canary-trigger-icon></canary-trigger-icon> `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Icon: StoryObj = {
  args: { kind: Kind.Icon },
  parameters: { viewport: { disable: true } },
};
