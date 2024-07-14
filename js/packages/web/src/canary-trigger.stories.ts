import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger";

const render = (_: any) => {
  return html` <canary-trigger></canary-trigger> `;
};

export default {
  render,
  title: "Public/canary-trigger",
  parameters: {
    sourceLink: "canary-trigger.stories.ts",
  },
} satisfies Meta;

export const Default: StoryObj = { args: {} };
