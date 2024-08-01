import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-tooltip";
import "./canary-callout-cal";

const render = (_: any) => {
  return html`
    <div style="width: 500px; margin: 24px">
      <canary-tooltip text="this is a tooltip">
        <canary-callout-cal forceShow></canary-callout-cal>
      </canary-tooltip>
    </div>
  `;
};

export default {
  render,
  title: "Public/canary-tooltip",
  parameters: {
    sourceLink: "canary-tooltip.stories.ts",
  },
} satisfies Meta;

export const Default: StoryObj = { args: {} };
