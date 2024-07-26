import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger-searchbar";
import "./canary-trigger-logo";

const render = ({ key }: any) => {
  if (!key) {
    return html` <canary-trigger-logo></canary-trigger-logo> `;
  }
  return html`
    <canary-trigger-searchbar .key=${key}></canary-trigger-searchbar>
  `;
};

export default {
  render,
  title: "Public/canary-trigger",
  parameters: { sourceLink: "canary-trigger.stories.ts" },
} satisfies Meta;

export const Logo: StoryObj = {
  args: {},
  parameters: { viewport: { disable: true } },
};

export const Searchbar_Cmdk: StoryObj = {
  args: { key: "cmdk" },
  parameters: { viewport: { disable: true } },
};

export const Searchbar_Slash: StoryObj = {
  args: { key: "slash" },
  parameters: { viewport: { disable: true } },
};

export const Searchbar_Mobile: StoryObj = {
  args: { key: "cmdk" },
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};
