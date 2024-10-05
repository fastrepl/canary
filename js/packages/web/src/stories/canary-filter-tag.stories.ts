import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "../components/canary-filter-tags";

enum Kind {
  Simple,
  WithLocalStorage,
  WithURLSync,
}

export default {
  title: "public-components/canary-filter-tags",
  component: "canary-filter-tags",
  parameters: { sourceLink: "components/canary-filter-tags.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Simple) {
      return html`
        <canary-filter-tags tags="Javascript,Typescript"> </canary-filter-tags>
      `;
    }

    if (kind === Kind.WithLocalStorage) {
      return html`
        <canary-filter-tags tags="JS,TS" local-storage-key="tags">
        </canary-filter-tags>
      `;
    }

    if (kind === Kind.WithURLSync) {
      const def = JSON.stringify([
        { tag: "Proxy", pattern: "a/b" },
        { tag: "SDK", pattern: "**/*" },
      ]);

      return html`
        <canary-filter-tags
          tags="Proxy,SDK"
          url-sync=${def}
        ></canary-filter-tags>
      `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Simple: StoryObj = {
  args: { kind: Kind.Simple },
};

export const WithLocalStorage: StoryObj = {
  args: { kind: Kind.WithLocalStorage },
};

export const WithURLSync: StoryObj = {
  args: { kind: Kind.WithURLSync },
};
