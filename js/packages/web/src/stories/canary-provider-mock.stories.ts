import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "../components/canary-root";
import "../components/canary-provider-mock";
import "../components/canary-modal";
import "../components/canary-trigger-searchbar";
import "../components/canary-content";
import "../components/canary-input";
import "../components/canary-search";
import "../components/canary-search-results";

enum Kind {
  Default,
}

export default {
  title: "public-components/canary-provider-mock",
  component: "canary-provider-mock",
  parameters: { sourceLink: "components/canary-provider-mock.stories.ts" },
  render: ({ kind }) => {
    if (kind === Kind.Default) {
      return html` <canary-root>
        <canary-provider-mock>
          <canary-modal>
            <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
            <canary-content slot="content">
              <canary-input slot="input"></canary-input>
              <canary-search slot="mode">
                <canary-search-results slot="body"></canary-search-results>
              </canary-search>
            </canary-content>
          </canary-modal>
        </canary-provider-mock>
      </canary-root>`;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Default: StoryObj = {
  args: { kind: Kind.Default },
};
