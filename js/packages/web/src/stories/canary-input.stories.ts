import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "../components/canary-filter-tags";

enum Kind {
  Autofocus,
  WithoutAutofocus,
}

export default {
  title: "public-components/canary-input",
  component: "canary-input",
  parameters: { sourceLink: "stories/canary-input.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Autofocus) {
      return html` <canary-input autofocus></canary-input> `;
    }

    if (kind === Kind.WithoutAutofocus) {
      return html` <canary-input></canary-input> `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Autofocus: StoryObj = {
  args: { kind: Kind.Autofocus },
};

export const WithoutAutofocus: StoryObj = {
  args: { kind: Kind.WithoutAutofocus },
};
