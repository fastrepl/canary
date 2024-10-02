import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-filter-tags";

enum Kind {
  Simple_1,
  Simple_2,
  Simple_3,
}

export default {
  title: "public-components/canary-filter-tags",
  component: "canary-filter-tags",
  parameters: { sourceLink: "components/canary-filter-tags.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Simple_1) {
      return html`
        <canary-filter-tags tags="JS,TS" local-storage-key="tags">
        </canary-filter-tags>
      `;
    }

    if (kind === Kind.Simple_2) {
      return html`
        <canary-filter-tags tags="Javascript,Typescript"> </canary-filter-tags>
      `;
    }

    if (kind === Kind.Simple_3) {
      return html`
        <canary-filter-tags tags="Proxy,SDK"> </canary-filter-tags>
      `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Simple_1: StoryObj = {
  args: { kind: Kind.Simple_1 },
};

export const Simple_2: StoryObj = {
  args: { kind: Kind.Simple_2 },
};

export const Simple_3: StoryObj = {
  args: { kind: Kind.Simple_3 },
};
