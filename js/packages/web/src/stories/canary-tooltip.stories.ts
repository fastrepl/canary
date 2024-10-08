import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "../components/canary-tooltip";
import "../components/canary-callout-cal";

export default {
  title: "public-components/canary-tooltip",
  parameters: { sourceLink: "components/canary-tooltip.stories.ts" },
  render: (_: any) => {
    return html`
      <div style="width: 500px; margin: 24px">
        <canary-tooltip text="this is a tooltip">
          <canary-callout-cal forceShow></canary-callout-cal>
        </canary-tooltip>
      </div>
    `;
  },
} satisfies Meta;

export const Default: StoryObj = { args: {} };
