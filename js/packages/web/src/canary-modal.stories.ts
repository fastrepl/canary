import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-modal";
import "./canary-trigger";
import "./canary-panel";
import "./canary-callout-cal";
import "./canary-callout-discord";

const render = (_: any) => {
  return html`
    <canary-modal>
      <canary-trigger slot="trigger"></canary-trigger>
      <canary-panel
        slot="body"
        key="key"
        endpoint="http://localhost:6006"
      ></canary-panel>
    </canary-modal>
  `;
};

export default {
  render,
  title: "Public/canary-modal",
  parameters: {
    sourceLink: "canary-modal.stories.ts",
  },
} satisfies Meta;

export const Default: StoryObj = { args: {} };
