import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger-logo";

enum Kind {
  Logo,
}

export default {
  title: "public-components/canary-trigger-logo",
  component: "canary-trigger-logo",
  parameters: { sourceLink: "components/canary-trigger.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Logo) {
      return html` <canary-trigger-logo></canary-trigger-logo> `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Logo: StoryObj = {
  args: { kind: Kind.Logo },
  parameters: { viewport: { disable: true } },
};
