import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger-searchbar";

const render = (_: any) => {
  return html` <canary-trigger-searchbar></canary-trigger-searchbar> `;
};

export default {
  render,
  title: "Public/canary-trigger-searchbar",
  parameters: {
    sourceLink: "canary-trigger-searchbar.stories.ts",
  },
} satisfies Meta;

export const Desktop: StoryObj = {
  args: {},
  parameters: { viewport: { disable: true } },
};
export const Mobile: StoryObj = {
  args: {},
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};
