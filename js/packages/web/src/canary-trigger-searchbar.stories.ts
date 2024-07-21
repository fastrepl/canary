import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger-searchbar";

const render = ({ key }: any) => {
  return html`
    <canary-trigger-searchbar .key=${key}></canary-trigger-searchbar>
  `;
};

export default {
  render,
  title: "Public/canary-trigger-searchbar",
  parameters: { sourceLink: "canary-trigger-searchbar.stories.ts" },
} satisfies Meta;

export const cmdk: StoryObj = {
  args: { key: "cmdk" },
  parameters: { viewport: { disable: true } },
};

export const slash: StoryObj = {
  args: { key: "slash" },
  parameters: { viewport: { disable: true } },
};

export const Mobile: StoryObj = {
  args: { key: "cmdk" },
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};
