import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-tabs-url";
import "./canary-tabs-source";

enum Kind {
  URL,
  Source,
}

export default {
  title: "Public/canary-tabs",
  parameters: { sourceLink: "components/canary-tabs.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.URL) {
      return html`<canary-tabs-url
        .tabs=${["All", "API"]}
        .selected=${"All"}
      ></canary-tabs-url>`;
    }

    if (kind === Kind.Source) {
      return html`<canary-tabs-source
        .tabs=${["Docs", "Issues", "Discussions"]}
        .selected=${"Docs"}
      ></canary-tabs-source>`;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const URL: StoryObj = {
  args: { kind: Kind.URL },
};

export const Source: StoryObj = {
  args: { kind: Kind.Source },
};
